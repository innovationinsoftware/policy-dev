mock "time" {
  data = {
    now = {
      hour = 0
      minute = 0
    }
  }
}
test {
  rules = {
    main = true
  }
}