mock "time" {
  data = {
    now = {
      hour = 9
      minute = 42
    }
  }
}
test {
  rules = {
    main = true
  }
}