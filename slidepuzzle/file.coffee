fs = require 'fs'

# 入力データの読込
exports.readInputData = (filename) ->
  str = String(fs.readFileSync(filename))

  lines = str.split("\n")
  rests = lines.shift().split ' '
  total = lines.shift()
  boards = []

  while(lines.length > 0)
    line = lines.shift()
    data = line.split ','
    if data.length is 3
      boards.push data

  rest:
    L:  rests[0]
    R: rests[1]
    U:    rests[2]
    D:  rests[3]
  total: total
  boards: boards

# 回答データの読込
exports.readAnswerData = (filename) ->
  str = String(fs.readFileSync(filename))

  lines = str.split("\n")
  answers = {}
  skips = {}

  while(lines.length > 0)
    line = lines.shift()
    data = line.split ','
    if data.length > 3
      key = data[0..2].join(',')
      if data[3] is 'SKIP'
        skips[key] = data[3]
      else
        answers[key] = data[3]

  [answers, skips]
