package com.finegamedesign.facetnated
{
    public class Model
    {
        internal static const EMPTY:int = -1;

        internal static var levels:Array = [
            {colorCount: 5, shapeCount: 5, columnCount: 7, rowCount: 5}
        ];

        internal var kill:int;
        internal var maxKill:int;
        internal var cellCount:int;
        internal var colorCount:int;
        internal var columnCount:int;
        internal var onContagion:Function;
        internal var onDie:Function;
        internal var rowCount:int;
        internal var shapeCount:int;
        internal var selectColor:Boolean;
        internal var selected:Array;
        internal var selectShape:Boolean;
        internal var table:Array;

        public function Model()
        {
        }

        internal function populate(levelParams:Object):void
        {
            for (var param:String in levelParams) {
                this[param] = levelParams[param];
            }
            table = [];
            cellCount = rowCount * columnCount;
            for (var c:int = 0; c < cellCount; c++) {
                var color:int = c % colorCount;
                var shape:int = int(c / colorCount) % shapeCount;
                var cell:int = 10 * shape + color;
                table.push(cell);
            }
            shuffle(table);
            selected = [];
            kill = 0;
            maxKill = columnCount * rowCount;
            trace("Model.populate: " + table.toString());
        }

        internal function getColor(c:int):int
        {
            return table[c] % 10;
        }

        internal function getShape(c:int):int
        {
            return table[c] / 10;
        }

        private function shuffle(array:Array):void
        {
            for (var i:int = array.length - 1; 1 <= i; i--) {
                var j:int = (i + 1) * Math.random();
                var tmp:* = array[i];
                array[i] = array[j];
                array[j] = tmp;
            }
        }

        internal function indexAt(column:int, row:int):int
        {
            return row * columnCount + column;
        }

        /**
         * Nothing selected yet.
         * Just mouse down.  Select that cell's address.  Selected is translucent.
         * Just mouse over and down adjacent to last selected address.  If matches properties of selection, then select that address.
         * Just mouse over and down not adjacent.  Do nothing.
         * Mouse up.  Judge selection of cell addresses.  Clear selection.  Delete the cells.
         */
        internal function select(i:int):Boolean
        {
            var push:Boolean = false;
            if (selected.length == 0) {
                push = true;
                selectColor = true;
                selectShape = true;
            }
            else {
                var tail:int = selected[selected.length - 1];
                if (tail == i) {
                    selected.pop();
                }
                else if (adjacent(tail, i)) {
                    if (selectColor) {
                        if (getColor(tail) == getColor(i)) {
                            push = true;
                            if (getShape(tail) != getShape(i)) {
                                selectShape = false;
                            }
                        }
                    }
                    if (selectShape) {
                        if (getShape(tail) == getShape(i)) {
                            push = true;
                            if (getColor(tail) != getColor(i)) {
                                selectColor = false;
                            }
                        }
                    }
                }
            }
            if (push) {
                var index:int = selected.indexOf(i);
                if (index <= -1) {
                    selected.push(i);
                }
                else {
                    selected.splice(index, 999);
                    push = false;
                }
            }
            return push;
        }

        internal function adjacent(i:int, j:int):Boolean
        {
            var adjacent:Boolean = false;
            var column0:int = i % columnCount;
            var column1:int = j % columnCount;
            if (Math.abs(column1 - column0) <= 1) {
                var row0:int = i / columnCount;
                var row1:int = j / columnCount;
                if (Math.abs(row1 - row0) <= 1) {
                    adjacent = true;
                }
            }
            return adjacent;
        }

        /**
         * Removed addresses if 3 or more.
         */
        internal function judge():Array
        {
            var selectedMin:int = 3;
            var removed:Array = [];
            if (selectedMin <= selected.length) {
                removed = selected.slice();
                trace("Model.judge: removed " + removed);
                for each(var address:int in removed) {
                    table[address] = EMPTY;
                }
            }
            selected = [];
            return removed;
        }

        internal function update():int
        {
            return win();
        }

        /**
         * TODO: Lose if no moves remaining.
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            var winning:int = 0;
            if (maxKill <= kill) {
                winning = 1;
            }
            else if (false) {
                winning = -1;
            }
            return winning;
        }
    }
}
