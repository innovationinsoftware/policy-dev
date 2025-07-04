mock "time" {
  data = {
    now = {
      hour = 12
      minute = 0
    }
  }
}
test {
  rules = {
    main = false
  }
}