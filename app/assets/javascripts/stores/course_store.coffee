McFly       = require 'mcfly'
Flux        = new McFly()
API         = require '../utils/api.coffee'


# Data
_course = {}
_persisted = {}


# Utilities
setCourse = (data, persisted=false, quiet=false) ->
  delete data['weeks']
  $.extend(true, _course, data)
  _persisted = $.extend({}, _course) if persisted
  CourseStore.emitChange() unless quiet

updateCourseValue = (key, value) ->
  _course[key] = value
  CourseStore.emitChange()

addCourse = ->
  setCourse {
    title: "",
    description: ""
    school: ""
    term: ""
    subject: ""
    expected_students: 0
    start: ""
    end: ""
  }


# Store
CourseStore = Flux.createStore
  getCourse: ->
    return _course
  restore: ->
    _course = $.extend({}, _persisted)
    CourseStore.emitChange()
, (payload) ->
  data = payload.data
  switch(payload.actionType)
    when 'RECEIVE_COURSE', 'CREATED_COURSE'
      setCourse data.course, true
      break
    when 'SAVED_COURSE'
      setCourse data.course, true, true
      break
    when 'UPDATE_COURSE'
      setCourse data.course
      break
    when 'ADD_COURSE'
      addCourse()
      break
  return true

module.exports = CourseStore