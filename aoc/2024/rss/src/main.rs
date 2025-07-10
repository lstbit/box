pub mod day_one;

use crate::day_one::{solve_p1, solve_p2};

fn main() {
    println!(
        "day_one p1: {}",
        solve_p1("../test_inputs/day_one/real.txt")
    );
    println!(
        "day_one p2: {}",
        solve_p2("../test_inputs/day_one/real.txt")
    );
}
