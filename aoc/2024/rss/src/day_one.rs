use std::fs;

pub fn solve_p1(input_path: &str) -> usize {
    let input = fs::read_to_string(input_path)
        .expect(format!("Failed to find file {}", input_path).as_str());

    let lines = input.split("\n");

    let mut left_list: Vec<usize> = vec![];
    let mut right_list: Vec<usize> = vec![];

    for line in lines {
        let pair: Vec<_> = line
            .split_whitespace()
            .map(|x| x.parse::<usize>().expect("failed to parse num"))
            .collect();

        if pair.len() >= 2 {
            left_list.push(pair[0]);
            right_list.push(pair[1]);
        }
    }

    left_list.sort();
    right_list.sort();

    let distances: Vec<usize> = left_list
        .into_iter()
        .zip(right_list.into_iter())
        .map(|(l, r)| l.abs_diff(r))
        .collect();

    distances.into_iter().sum()
}

pub fn solve_p2(input_path: &str) -> usize {
    let input = fs::read_to_string(input_path)
        .expect(format!("Failed to find file {}", input_path).as_str());

    let lines = input.split("\n");

    let mut left_list: Vec<usize> = vec![];
    let mut right_list: Vec<usize> = vec![];
    let mut score: usize = 0;

    for line in lines {
        let pair: Vec<_> = line
            .split_whitespace()
            .map(|x| x.parse::<usize>().expect("failed to parse num"))
            .collect();

        if pair.len() >= 2 {
            left_list.push(pair[0]);
            right_list.push(pair[1]);
        }
    }

    for num in left_list {
        let cloned_list = right_list.clone();
        let count = cloned_list.into_iter().filter(|&x| x == num).count();

        score = score + (num * count)
    }
    score
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_p1() {
        // We have to use a path relative to the location of cargo.toml
        // as that is where the tests are ran from
        let got = solve_p1("./test_inputs/day_one/test.txt");
        let want = 11;
        assert_eq!(got, want)
    }

    #[test]
    fn test_solve_p2() {
        let got = solve_p2("./test_inputs/day_one/test.txt");
        let want = 31;
        assert_eq!(got, want)
    }
}
