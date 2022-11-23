// rustc a.rs
// ./a
use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> std::io::Result<()> {
    let f = File::open("input")?;
    let mut reader = BufReader::new(f);


    let mut line = String::new();
    let len = reader.read_line(&mut line)?;
    println!("First line is {line} and {len} bytes long");
    let number = line.trim_end().parse::<i32>().unwrap();

    fn counting<R: BufRead> ( previous: i32, count: i32, line: &mut String, reader: &mut R ) -> Option<i32> {
        line.clear();
        let len = reader.read_line(line).ok()?;
        if len == 0  { return Some(count) };
        let number = line.trim_end().parse::<i32>().unwrap();
        match number > previous {
            true => counting(number, count + 1, line, reader),
            false => counting(number, count, line, reader),
        }
    }
    let ref mut mut_line = line;
    let res = counting(number, 0, mut_line, &mut reader).unwrap();
    println!("The answer is {res}");

    Ok(())
}
