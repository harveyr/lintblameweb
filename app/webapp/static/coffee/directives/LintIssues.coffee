angular.module(DIRECTIVE_MODULE).directive 'lintIssues', ($rootScope) ->
    directive =
        replace: true
        template: """
            <div class="lint-issues" ng-class="{demoted: demotions[path]}">
                <div class="path">
                    <span class="label {{countClass}}">{{totalCount}}</span>
                        &nbsp;
                    <span class="dim">{{pathParts[0]}}/</span><strong>{{pathParts[1]}}</strong>

                    <div class="pull-right">
                        <a ng-click="demote(path)">
                            <span ng-show="!demotions[path]"
                                class="glyphicon glyphicon-thumbs-down dim hover-bright">
                            </span>
                            <span ng-show="demotions[path]"
                                class="glyphicon glyphicon-thumbs-up dim hover-bright">
                            </span>
                        </a>
                    </div>
                </div>
                <div ng-repeat="line in sortedLines" class="line-wrapper" ng-show="!demotions[path]">
                    <div class="line">
                        {{line}}
                    </div>
                    <div class="detail">
                        <code class="code">
                            {{data.lines[line - 1]}}
                        </code>
                        <table>
                            <tr ng-repeat="issue in issuesByLine[line]" class="issue">
                                <td class="reporter">
                                    {{issue.reporter}}
                                    {{issue.code}}
                                </td>
                                <td class="{{blameClass(line)}}">
                                    [{{blameLine(issue.line)}}]
                                </td>
                                <td>
                                    {{issue.message}}
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        """
        link: (scope) ->
            # pass

            scope.update = ->
                if not _.has scope.lintResults, scope.path
                    return

                scope.data = scope.lintResults[scope.path]
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

                if totalCount
                    scope.countClass = 'label-warning'
                else
                    scope.countClass = 'label-success'

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
                return scope.data.blame[line - 1]

            scope.blameClass = (line) ->
                cls = 'blame'
                lineBlame = scope.blameLine(line)
                if lineBlame == $rootScope.vcsName or lineBlame == 'Not Committed Yet'
                    cls += ' blame-me'
                cls

            scope.$watch 'lastRefresh', ->
                scope.update()

            scope.demote = (path) ->
                scope.$emit 'demote', path
