angular.module(DIRECTIVE_MODULE).directive 'savedTarget', ($rootScope, LocalStorage) ->
    directive =
        replace: true
        template: """
            <div class="saved-target">
                <div class="save-details">
                    <a ng-click="loadSavePath(path)">
                        <span class="dim">{{m.pathHead}}/</span><strong>{{m.pathTail}}</strong>
                    </a>
                    <div class="pull-right highlight" ng-show="m.bundle.branchMode">
                        Br
                    </div>
                </div>
                <div class="small actions">
                    <a class="danger" ng-click="deleteSave()">
                        <span class="glyphicon glyphicon-remove-circle"></span>
                    </a>
                </div>
            </div>
        """
        link: (scope) ->
            scope.m =
                path: scope.path
                
            parts = scope.path.split('/')
            scope.m.pathHead = parts[0...parts.length - 1].join('/')
            scope.m.pathTail = parts[parts.length - 1]

            # if scope.path.length > 20
            #     frag = scope.path.substr(17)
            #     scope.m.path = "...#{frag}"

            if _.has scope.data, 'saveName'
                scope.m.saveName = scope.data.saveName

            update = ->
                scope.m.bundle = LocalStorage.savedLintBundle scope.path
                if not scope.m.bundle
                    throw "Unable to get saved bundle for path #{scope.path}"

            scope.saveNameChange = ->
                LocalStorage.setSaveName scope.path, scope.m.saveName

            scope.deleteSave = ->
                LocalStorage.deleteSave scope.path                

            update()

            LocalStorage.addListener ->
                update()
