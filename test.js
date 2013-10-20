TestClass = function() {
  this.a = 2
  this.fromJs = function () {
    return "hey from javascript land"
  }
  this.addTwo = function(num) {
    return num + 2
  }
  this.object = { prop: 'val' }
  this.initials = function() {
    var first = this.fullName.split(' ')[0]
    var last = this.fullName.split(' ')[1]
    return first[0] + last[0]
  }
}
