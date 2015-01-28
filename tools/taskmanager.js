//-----------------------------------------------------------------------------
// A simple task manager for use with Grunt. Avoids duplicate subtasks.
//
// Compile using the command:
// $ tsc --module commonjs tools/taskmanager.ts
;
// The state of flattening a tree containing only leaf nodes. The output
// keeps left-to-right order, and only contains the first occurence in the
// list of the node entry in the tree.
var FlatteningState = (function () {
    // Create an initial state with a single top-level name in the queue.
    function FlatteningState(name) {
        // Flattened tree seen so far.
        this.flattened_ = [];
        // Elements still to be flattened.
        this.queue_ = [];
        // Elements seen.
        this.seen_ = {};
        this.queue([name]);
    }
    // True when the given node name has been seen before.
    FlatteningState.prototype.haveSeen = function (name) {
        return (name in this.seen_);
    };
    // True all nodes have been flattened.
    FlatteningState.prototype.isFlattened = function () {
        return (this.queue_.length == 0);
    };
    // unfold a node in the flattening process. This either adds it to the
    // list of flattened nodes, or adds its children to the queue. Either way,
    // the node is marked as seen.
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
    // Add node names to the queue.
    FlatteningState.prototype.queue = function (toQueue) {
        this.queue_ = toQueue.concat(this.queue_);
    };
    // Flatten the state w.r.t. the given index.
    FlatteningState.prototype.flatten = function (index) {
        var unfoldWrtIndex = this.unfoldNode.bind(this, index);
        while (!this.isFlattened()) {
            unfoldWrtIndex(this.queue_.shift());
        }
        return this.flattened_;
    };
    return FlatteningState;
})();
// Manager managed tasks so that you add entries with sub-entries, and you
// can get a flattened and de-duped list of leaf-tasks as output.
var Manager = (function () {
    function Manager() {
        this.taskIndex_ = {};
    }
    // Depth first search keep track of path and checking for loops for each
    // new node. Returns list of all cycles found.
    Manager.prototype.getCycles = function (name) {
        // The |agenda| holds set of paths explored so far. The format for each
        // agenda entry is: [child, patent, grandparent, etc]
        // An invariant of the the agenda is that each member is a non-empty
        // string-list.
        var agenda = [[name]];
        var cyclicPaths = [];
        while (agenda.length > 0) {
            // Get the next path to explore further.
            var nextPath = agenda.shift();
            // If this is a non-leaf node, search all child nodes/paths
            var nodeToUnfold = nextPath[0];
            if (nodeToUnfold in this.taskIndex_) {
                // For each child of
                var children = this.taskIndex_[nodeToUnfold];
                children.forEach(function (child) {
                    // Extends the old path with a new one with child added to the
                    // front. We use slice(0) to make a copy of the path.
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
    // The |add| method will throw an exception if a circular dependency is
    // added.
    Manager.prototype.add = function (name, subtasks) {
        this.taskIndex_[name] = subtasks;
        // Check for resulting circular dependency.
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
exports.Manager = Manager; // class Manager
