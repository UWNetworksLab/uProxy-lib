var TaskManager;
(function (TaskManager) {
    ;
    var FlatteningState = (function () {
        function FlatteningState(name) {
            this.flattened_ = [];
            this.queue_ = [];
            this.seen_ = {};
            this.queue([name]);
        }
        FlatteningState.prototype.haveSeen = function (name) {
            return (name in this.seen_);
        };
        FlatteningState.prototype.isFlattened = function () {
            return (this.queue_.length == 0);
        };
        FlatteningState.prototype.unfoldNode = function (index, name) {
            if (this.haveSeen(name)) {
                return;
            }
            this.seen_[name] = true;
            if (name in index) {
                this.queue(index[name]);
            }
            else {
                this.flattened_.push(name);
            }
        };
        FlatteningState.prototype.queue = function (toQueue) {
            this.queue_ = toQueue.concat(this.queue_);
        };
        FlatteningState.prototype.flatten = function (index) {
            var unfoldWrtIndex = this.unfoldNode.bind(this, index);
            while (!this.isFlattened()) {
                unfoldWrtIndex(this.queue_.shift());
            }
            return this.flattened_;
        };
        return FlatteningState;
    })();
    var Manager = (function () {
        function Manager() {
            this.taskIndex_ = {};
        }
        Manager.prototype.getCycles = function (name) {
            var agenda = [[name]];
            var cyclicPaths = [];
            while (agenda.length > 0) {
                var nextPath = agenda.shift();
                var nodeToUnfold = nextPath[0];
                if (nodeToUnfold in this.taskIndex_) {
                    var children = this.taskIndex_[nodeToUnfold];
                    children.forEach(function (child) {
                        var newExtendedPath = nextPath.slice(0);
                        newExtendedPath.unshift(child);
                        if (nextPath.indexOf(child) !== -1) {
                            cyclicPaths.push(newExtendedPath);
                        }
                        else {
                            agenda.push(newExtendedPath);
                        }
                    });
                }
            }
            return cyclicPaths;
        };
        Manager.prototype.add = function (name, subtasks) {
            this.taskIndex_[name] = subtasks;
            var cycles = this.getCycles(name);
            if (cycles.length > 0) {
                throw new Error('Cyclic dependencies: ' + cycles.toString());
            }
        };
        Manager.prototype.getUnflattened = function (name) {
            if (!(name in this.taskIndex_)) {
                throw (name + " is not in taskIndex.");
            }
            return this.taskIndex_[name];
        };
        Manager.prototype.get = function (name) {
            return (new FlatteningState(name)).flatten(this.taskIndex_);
        };
        Manager.prototype.list = function () {
            return Object.keys(this.taskIndex_);
        };
        return Manager;
    })();
    TaskManager.Manager = Manager;
})(TaskManager || (TaskManager = {}));
var exports = (exports || {});
exports.Manager = TaskManager.Manager;
//# sourceMappingURL=taskmanager.js.map