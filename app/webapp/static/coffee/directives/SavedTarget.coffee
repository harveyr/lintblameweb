angular.module(DIRECTIVE_MODULE).directive 'savedTarget', ($rootScope, LocalStorage) ->
    directive =
        replace: true
        template: """
            <div class="saved-target" ng-click="click()">
                <input type="text"
                    class="form-control code"
                    ng-model="m.saveName"
                    ng-change="saveNameChange()"
                    placeholder="Save Name">

                <div class="dim">
                    <span class="tiny">
                        {{m.path}}
                    </span>
                </div>
                <div>
                    <small>
                        <a ng-click="loadSavePath(path)">Load</a>
                    </small>
                </div>
            </div>
        """
        link: (scope) ->
            scope.m =
                path: scope.path
                
            if scope.path.length > 20
                frag = scope.path.substr(17)
                scope.m.path = "...#{frag}"

            if _.has scope.data, 'saveName'
                scope.m.saveName = scope.data.saveName

            scope.saveNameChange = ->
                LocalStorage.setSaveName scope.path, scope.m.saveName

            scope.click = ->
                console.log 'click'

