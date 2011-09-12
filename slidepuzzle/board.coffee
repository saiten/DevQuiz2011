
module.exports = class Board
  constructor: (width, height, boardData, debug = false) ->
    @key = [ width, height, boardData ].join(',')
    @width = parseInt(width)
    @height = parseInt(height)
    @debug = debug

    @setBoard(boardData)
    @createAdjacents()
    @createDistance()

  setBoard: (boardData) ->
    @board = []
    for index in [0..boardData.length-1]
      c = boardData.charAt(index)
      if c is '='
        n = -1
      else
        n = c.charCodeAt()
        n = if n >= 65 then n-55 else n-48
      @board.push n

    # 解答ボード作成
    @answer = []
    piece = 1
    for index in [0..@board.length-1]
      if @board[index] is -1
        @answer.push -1
      else
        @answer.push piece
      piece += 1

    index = @answer.length-1
    index -= 1 while(@answer[index] is -1)
    @answer[index] = 0
    console.log drawBoard(@width, @height, @answer) if @debug

    @history = []
    @count = 0
    @space = @board.indexOf(0)

  search: ->
    count = 0
    solve = null

    _search = (limit, space, history, lower) =>
      if (history.length-1) is limit
        if @isGoal()
          count += 1
          dump = history.concat()
          dump.shift()
          solve = dump.map (e) -> e[1]
      else
        for adj in @adjacents[space]
          target = adj[0]
          val = @board[target]
          continue if history[history.length-1][0] is val

          @board[space] = val
          @board[target] = 0
          history.push [val, adj[1]]

          newLower = lower - @distances[val][target] + @distances[val][space]
          if newLower + (history.length-1) <= limit
            _search(limit, target, history, newLower)

          history.pop()
          @board[space] = 0
          @board[target] = val

    n = @getDistance()
    console.log "lower = #{n}" if @debug

    st = new Date()
    for x in [n..100]
      console.log "move : #{x}" if @debug
      _search x, @board.indexOf(0), [ [-1,''] ], n
      break if count > 0 or (new Date().getTime() - st.getTime())/1000 > 120

    solve

  getDistance: () ->
    d = 0
    for val,index in @board
      d += @distances[val][index] if val > 0
    d

  isGoal: ->
    for val, index in @board
      return false if @answer[index] isnt val
    true

  check: (solve) ->
    space = @board.indexOf(0)
    for mv in solve
      [next] = @adjacents[space].filter (e) ->
        e[1] is mv
      if next?
        @board[space] = @board[next[0]]
        @board[next[0]] = 0
        space = next[0]

    if @isGoal
      console.log @toString()
      console.log "ok!"

  canMove: (x, y) ->
    0 <= x < @width and 0 <= y < @height and @board[y*@width + x] isnt -1

  drawBoard = (width, height, board, lineSep = "\n", colSep = "") ->
    s = ""
    for y in [0..height-1]
      st = y * width
      row = board[st..st+width-1].map (val) ->
        if val is -1
          '='
        else if val < 10
          String.fromCharCode(48+val)
        else
          String.fromCharCode(55+val)

      s += row.join(colSep) + lineSep
    s

  toString: (lineSep = "\n", colSep = "") ->
    drawBoard(@width, @height, @board, lineSep, colSep)

  # 隣接テーブル作成
  createAdjacents: ->
    @adjacents = []
    for index in [0..@board.length-1]
      [x, y] = [ index % @width, Math.floor(index / @width) ]
      adjacent = []
      adjacent.push [index - @width, 'U'] if @canMove(x, y-1)
      adjacent.push [index + @width, 'D'] if @canMove(x, y+1)
      adjacent.push [index - 1, 'L']      if @canMove(x-1, y)
      adjacent.push [index + 1, 'R']      if @canMove(x+1, y)
      @adjacents.push adjacent

  # 距離テーブル作成
  createDistance: ->
    @distances = [[]]

    wall = 0
    goal = 0
    for piece in [0..@board.length-1]
      distance = []
      if @board[piece] is -1
        wall += 1
      else
        goal = piece

        for index in [0..@board.length-1]
          path = @searchDistance(index, goal)
          distance.push (if path.length > 0 then path.length - 1 else 0)

      @distances.push distance

  # A* 経路探索
  searchDistance: (start, goal) ->
    [gx, gy] = [goal % @width, Math.floor(goal / @width)]

    hs = (node) =>
      [x, y] = [node.index % @width, Math.floor(node.index / @width)]
      Math.abs(gx-x) + Math.abs(gy-y)

    nodes = []
    for val, index in @board
      nodes.push {
        index: index
        gs: Number.MAX_VALUE
        fs: Number.MAX_VALUE
        prev: null
        done: false
        isGoal: goal is index
        isWall: val is -1
      }

    [startNode] = nodes.filter (e) -> e.index is start
    return [] if startNode.isWall
    startNode.gs = 0
    startNode.fs = startNode.gs + hs(startNode)

    open = [ startNode ]

    _next = =>
      targetIndex = -1
      minScore = Number.MAX_VALUE
      u = null
      for node, index in open
        continue if node.done
        if node.fs < minScore
          minScore = node.fs
          u = node
          targetIndex = index

      return null unless u?

      open.splice targetIndex, 1
      u.done = true
      return u if u.isGoal

      for adj in @adjacents[u.index]
        index = adj[0]
        v = nodes[index]
        continue if v.done or v.isWall
        if u.fs + 1 < v.fs
          v.gs = u.gs + 1
          v.fs = v.gs + hs(v)
          v.prev = u
          open.push v if open.indexOf(v) is -1

      _next()

    v = _next()
    path = []
    while(v?)
      path.push v.index
      v = v.prev
    path.reverse()
