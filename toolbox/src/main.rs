use axum::{extract::Path, http::StatusCode, response::IntoResponse, routing::get, Router};
use std::net::SocketAddr;
use std::path::PathBuf;
use tracing::info;

const AOC_BASE: &str = "https://adventofcode.com";

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();
    tracing_subscriber::fmt::init();

    let app = Router::new().route("/input/{year}/{day}", get(fetch_input));

    let addr = SocketAddr::from(([127, 0, 0, 1], 8080));
    info!("listening on {addr}");

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn fetch_input(Path((year, day)): Path<(u16, u8)>) -> impl IntoResponse {
    let cache_path = cache_path(year, day);

    if cache_path.exists() {
        match std::fs::read_to_string(&cache_path) {
            Ok(body) => {
                info!("cache hit: {year}/day/{day}");
                return (StatusCode::OK, body);
            }
            Err(e) => {
                info!("cache read error (will refetch): {e}");
            }
        }
    }

    let session = match session_token() {
        Ok(s) => s,
        Err(msg) => {
            return (StatusCode::INTERNAL_SERVER_ERROR, msg);
        }
    };

    let url = format!("{AOC_BASE}/{year}/day/{day}/input");
    let client = reqwest::Client::new();
    let resp = match client
        .get(&url)
        .header("Cookie", format!("session={session}"))
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => {
            return (
                StatusCode::BAD_GATEWAY,
                format!(r#"{{"error":"request failed: {e}"}}"#),
            );
        }
    };

    let status = resp.status();
    let body = match resp.text().await {
        Ok(b) => b,
        Err(e) => {
            return (
                StatusCode::BAD_GATEWAY,
                format!(r#"{{"error":"reading response failed: {e}"}}"#),
            );
        }
    };

    if !status.is_success() {
        let escaped = body
            .replace('\\', "\\\\")
            .replace('"', "\\\"")
            .replace('\n', "\\n")
            .replace('\r', "\\r");
        return (
            StatusCode::from_u16(status.as_u16()).unwrap(),
            format!(r#"{{"error":"AoC returned {status}","body":"{escaped}"}}"#),
        );
    }

    if let Some(parent) = cache_path.parent() {
        std::fs::create_dir_all(parent).unwrap();
    }
    std::fs::write(&cache_path, &body).unwrap();
    info!("cached: {year}/day/{day}");

    (StatusCode::OK, body)
}

fn session_token() -> Result<String, String> {
    if let Ok(s) = std::env::var("AOC_SESSION") {
        return Ok(s);
    }
    let path = config_dir().join("session");
    match std::fs::read_to_string(&path) {
        Ok(s) => {
            let trimmed = s.trim().to_string();
            if trimmed.is_empty() {
                Err(format!(r#"{{"error":"{} is empty"}}"#, path.display()))
            } else {
                Ok(trimmed)
            }
        }
        Err(_) => Err(
            format!(r#"{{"error":"AOC_SESSION not set and no session file at {}"}}"#, path.display())
        ),
    }
}

fn config_dir() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home).join(".config").join("aoc")
}

fn cache_path(year: u16, day: u8) -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home)
        .join(".cache")
        .join("aoc")
        .join(year.to_string())
        .join(format!("{day:02}.txt"))
}
