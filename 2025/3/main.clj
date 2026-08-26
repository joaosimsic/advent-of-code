(ns main
  (:require [clojure.string :as str]))

(defn highest-joltage
  ([bank] (highest-joltage bank 12))
  ([bank k]
   (let [digits (mapv #(Character/digit % 10) bank)
         n (count digits)
         to-drop (- n k)]
     (if (<= n k)
       (reduce #(+ (* %1 10) %2) 0 digits)
       (let [[stack _]
             (reduce (fn [[st drops] curr]
                       (let [[new-st remaining-drops]
                             (loop [s st
                                    d drops]
                               (if (and (seq s)
                                        (pos? d)
                                        (< (peek s) curr))
                                 (recur (pop s) (dec d))
                                 [s d]))]
                         [(conj new-st curr) remaining-drops]))
                     [[] to-drop]
                     digits)]
         (->> stack
              (take k)
              (reduce #(+ (* %1 10) %2) 0)))))))

(defn -main []
  (let [total-joltage (->> (slurp "input.txt")
                           (str/split-lines)
                           (remove str/blank?)
                           (map #(highest-joltage % 12))
                           (reduce +))]

    (println "Total joltage: " (str total-joltage))))

(-main)
