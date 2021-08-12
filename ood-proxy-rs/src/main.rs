fn main() {
  println!("Hello Open OnDemand!");
}

pub fn ood() -> String {
  return format!("Open OnDemand");
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_ood() {
    assert_eq!(ood(), "Open OnDemand");
  }
}
