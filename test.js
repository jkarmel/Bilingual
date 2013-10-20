TestClass = function() {
  this.a = 2
  this.fromJs = function () {
    return "hey from javascript land"
  }
  this.addTwo = function(num) {
    return num + 2
  }
  this.object = { prop: 'val' }
}
Person = function() {
  this.initials = function() {
    return this.firstName[0] + this.lastName[0]
  }
  this.fullName = function() {
    return this.firstName + ' ' + this.lastName
  }
}
