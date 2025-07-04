mock "time" {
  data = {
    now = {
      hour = 13
      minute = 0
    }
  }
}
test {
  rules = {
    main = false
  }
}