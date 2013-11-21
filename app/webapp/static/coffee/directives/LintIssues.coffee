angular.module(DIRECTIVE_MODULE).directive 'lintIssues', ($rootScope) ->
    directive =
        replace: true
        template: """
            <div class="lint-issues" ng-class="{demoted: demotions[path]}">
                <div class="path">
                    <span class="label {{countClass}}">{{totalCount}}</span>
                        &nbsp;
                    <span class="path-parts">
                        <span class="head">{{pathHead}}/</span><span class="tail">{{pathTail}}</span>
                    </span>

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

                splitStr = scope.acceptedLintPath
                if splitStr.charAt 0 == '~'
                    splitStr = splitStr.substr(1)
                relPath = scope.path.split(splitStr).pop()
                if relPath.charAt(0) == '/'
                    relPath = relPath.substr(1)

                parts = relPath.split('/')
                scope.pathTail = parts.pop()
                scope.pathHead = parts.join('/')

                # pathParts = scope.path.split('/')
                # pathHead = ''
                # scope.pathTail = pathParts.pop()
                # while pathHead.length < 30
                #     nextPart = pathParts.pop()
                #     if _.isUndefined nextPart
                #         break
                #     pathHead = nextPart + "/#{pathHead}"
                # if pathHead.length < scope.path.length - scope.pathTail.length
                #     pathHead = '...' + pathHead
                # scope.pathHead = pathHead.substr(1)
 
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
