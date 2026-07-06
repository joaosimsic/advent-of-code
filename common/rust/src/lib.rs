use std::io::Read;

pub fn read_stdin() -> String {
    let mut buf = String::new();
    std::io::stdin().read_to_string(&mut buf).unwrap();
    buf
}

pub fn fetch_input(year: u16, day: u8) -> String {
    let url = format!("http://localhost:8080/input/{year}/{day}");
    ureq::get(&url).call().into_string().unwrap()
}
