package com.finegamedesign.facetnated
{
    public class Model
    {
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
