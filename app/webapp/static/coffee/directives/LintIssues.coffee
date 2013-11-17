angular.module(DIRECTIVE_MODULE).directive 'lintIssues', () ->
    directive =
        replace: true
        scope:
            path: '='
            data: '='
        template: """
            <div class="lint-issues">
                <div>
                    <span class="label label-warning">{{totalCount}}</span>
                        &nbsp;
                    <span class="dim">{{pathParts[0]}}/</span><strong>{{pathParts[1]}}</strong>                    
                </div>
                <div ng-repeat="line in sortedLines" class="issue">
                    <div ng-repeat="issue in issuesByLine[line]" class="issue">
                        <div class="line">
                            {{issue.line}}<span ng-show="issue.column">:{{issue.column}}</span>
                        </div>
                        <div class="reporter">
                            [{{issue.reporter}}<span ng-show="issue.code"> {{issue.code}}</span>]
                        </div>
                        <div class="blame">
                            [{{blameLine(issue.line)}}]
                        </div>
                        <div class="message">
                            {{issue.message}}
                        </div>
                    </div>
                </div>
            </div>
        """
        link: (scope) ->
            # pass

            scope.update = ->
                issuesByLine = {}
                totalCount = 0
                for issue in scope.data.issues
                    line = issue.line
                    if not _.has issuesByLine, line
                        issuesByLine[line] = []
                    issuesByLine[line].push issue
                    totalCount += 1

                scope.issuesByLine = issuesByLine
                scope.totalCount = totalCount

                lineInts = _.map issuesByLine, (issue, line) ->
                    parseInt(line, 10)
                scope.sortedLines = lineInts.sort (a, b) ->
                    a - b

                pathParts = scope.path.split('/')            
                scope.pathParts = []
                if pathParts.length > 1
                    scope.pathParts.push(
                        pathParts[0...pathParts.length - 1].join('/')
                    )
                else
                    scope.pathParts.push ''
                scope.pathParts.push pathParts[pathParts.length - 1]

            scope.blameLine = (line) ->
                return scope.data.blame[line]

            scope.$watch 'data', ->
                console.log 'update!'
                scope.update()
