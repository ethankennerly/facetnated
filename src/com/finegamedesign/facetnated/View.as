package com.finegamedesign.facetnated
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class View
    {
        private static var filters:Array = [
            new Filter0().getChildAt(0).filters,
            new Filter1().getChildAt(0).filters,
            new Filter2().getChildAt(0).filters,
            new Filter3().getChildAt(0).filters,
            new Filter4().getChildAt(0).filters
        ];
        private static var shapeClasses:Array = [
            Shape0,
            Shape1,
            Shape2,
            Shape3,
            Shape4
        ];

        internal var model:Model;
        internal var originalRoomHeight:int = -1;
        internal var originalRoomWidth:int = -1;
        internal var originalTileWidth:int = 80;
        internal var room:DisplayObjectContainer;
        internal var scale:Number;
        internal var tileWidth:int;
        internal var table:Array;
        private var isMouseDown:Boolean;
        private var mouseJustPressed:Boolean;

        public function View()
        {
            table = [];
        }

        /**
         * Position each object in the model's grid into the center-aligned room and scale to fit in room.
         * Adds property "model" to each cell in table.
         */
        internal function populate(model:Model, room:DisplayObjectContainer):void
        {
            this.model = model;
            this.room = room;
            if (originalRoomWidth <= 0) {
                originalRoomHeight = room.height;
                originalRoomWidth = room.width;
            }
            var heightPerTile:int = originalRoomHeight / model.rowCount;
            var widthPerTile:int = originalRoomWidth / model.columnCount;
            if (heightPerTile < widthPerTile) {
                tileWidth = heightPerTile;
            }
            else {
                tileWidth = widthPerTile;
            }
            scale = tileWidth / originalTileWidth;
            room.width = model.columnCount * tileWidth;
            room.height = model.rowCount * tileWidth;
            table = [];
            for (var i:int = 0; i < model.table.length; i++){
                var s:int = model.table[i].shape;
                var c:int = model.table[i].color;
                var shapeClass:Class = shapeClasses[s];
                var cell:MovieClip = new shapeClass();
                cell.filters = filters[c];
                cell.scaleX = scale;
                cell.scaleY = scale;
                position(cell, i, model.columnCount, model.rowCount);
                cell.addEventListener(MouseEvent.MOUSE_DOWN, selectDown, false, 0, true);
                cell.addEventListener(MouseEvent.ROLL_OVER, select, false, 0, true);
                cell.model = model.table[i];
                cell.buttonMode = true;
                room.addChild(cell);
                table.push(cell);
            }
            room.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
            room.addEventListener(MouseEvent.MOUSE_UP, judge, false, 0, true);
        }

        private function position(mc:MovieClip, i:int, columnCount:int, rowCount:int):void
        {
            mc.x = positionX(i, columnCount);
            mc.y = positionY(i, columnCount, rowCount);
        }

        private function positionX(i:int, columnCount:int):Number
        {
            var column:int = i % columnCount;
            return tileWidth * (0.5 + column - columnCount * 0.5);
        }

        private function positionY(i:int, columnCount:int, rowCount:int):Number
        {
            var row:int = i / columnCount;
            return tileWidth * (0.5 + row - rowCount * 0.5);
        }

        internal function columnAt(roomX:Number, columnCount):int
        {
            return roomX / tileWidth + columnCount * 0.5;
        }

        internal function rowAt(roomY:Number, rowCount:int):int
        {
            return roomY / tileWidth + rowCount * 0.5;
        }

        private function mouseDown(event:MouseEvent):void
        {
            mouseJustPressed = !isMouseDown;
            isMouseDown = true;
        }

        private function mouseUp(event:MouseEvent):void
        {
            mouseJustPressed = false;
            isMouseDown = false;
        }

        private function selectDown(e:MouseEvent):void
        {
            mouseDown(e);
            select(e);
        }

        private function select(e:MouseEvent):void
        {
            if (!isMouseDown) {
                return;
            }
            var mc:MovieClip = MovieClip(e.currentTarget);
            var index:int = mc.model.index;
            // trace("View.select: index " + index);
            var selected:Boolean = model.select(index);
            updateCells(model, table);
        }

        internal function update():void
        {
            updateCells(model, table);
        }

        private function updateCells(model:Model, table:Array):void
        {
            for (var t:int = 0; t < table.length; t++) {
                var mc:MovieClip = table[t];
                var index:int;
                if (mc.model == null) {
                    index = Model.EMPTY;
                }
                else {
                    index = mc.model.index;
                }
                if (0 <= model.selected.indexOf(index)) {
                    mc.alpha = 0.25;
                }
                else {
                    mc.alpha = 1.0;
                }
                if (index <= Model.EMPTY) {
                    room.removeChild(mc);
                    table.splice(t, 1);
                }
                else {
                    position(mc, index, model.columnCount, 
                        model.rowCount);
                }
            }
        }

        /**
         * Remove cells corresponding to model's addresses.
         */
        private function judge(e:MouseEvent):void
        {
            mouseUp(e);
            model.judge();
            updateCells(model, table);
        }

        internal function clear():void
        {
            model.clear();
            updateCells(model, table);
            for (var t:int = 0; t < table.length; t++) {
                var mc:MovieClip = table[t];
                if (room.contains(mc)) {
                    room.removeChild(mc);
                }
                table.splice(t, 1);
            }
        }
    }
}
