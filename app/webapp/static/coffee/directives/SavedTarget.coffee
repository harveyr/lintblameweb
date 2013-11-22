angular.module(DIRECTIVE_MODULE).directive 'savedTarget', ($rootScope, LocalStorage) ->
    directive =
        replace: true
        template: """
            <div class="saved-target">
                <input type="text"
                    class="form-control code"
                    ng-model="m.saveName"
                    ng-change="saveNameChange()"
                    placeholder="Save Name">

                <div class="tiny save-details">
                    <span class="dim">
                        {{m.path}}
                    </span>
                    <div class="pull-right highlight">
                        Br
                    </div>
                </div>
                <div class="small actions">
                    <a class="danger" ng-click="deleteSave()">
                        <span class="glyphicon glyphicon-remove-circle"></span>
                    </a>
                    <div class="pull-right">
                        <a ng-click="loadSavePath(path)">
                            <span class="glyphicon glyphicon-arrow-right"></span>
                        </a>
                    </div>
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

            scope.deleteSave = ->
                LocalStorage.deleteSave scope.path                
