mock "time" {
  data = {
    now = {
      hour = 9
      minute = 0
    }
  }
}
test {
  rules = {
    main = false
  }
}