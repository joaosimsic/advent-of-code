(ns main
  (:require [clojure.string :as str]))

(defn highest-joltage [bank]
  (let [digits (map #(Character/digit % 10) bank)]
    (loop [remaining (rest digits)
           max-first (first digits)
           best-pair -1]
      (if (empty? remaining)
        best-pair
        (let [curr (first remaining)
              candidate (+ (* max-first 10) curr)]
          (recur (rest remaining)
                 (max max-first curr)
                 (max best-pair candidate)))))))

(defn -main []
  (let [total-joltage (->> (slurp "input.txt")
                           (str/split-lines)
                           (remove str/blank?)
                           (map highest-joltage)
                           (reduce +))]

    (println "Total joltage: " total-joltage)))

(-main)
