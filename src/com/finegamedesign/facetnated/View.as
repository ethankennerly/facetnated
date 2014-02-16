package com.finegamedesign.facetnated
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;

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

        internal var room:DisplayObjectContainer;
        internal var originalRoomHeight:int = -1;
        internal var originalRoomWidth:int = -1;
        internal var originalTileWidth:int = 80;
        internal var scale:Number;
        internal var tileWidth:int;
        internal var table:Array;

        public function View()
        {
            table = [];
        }

        /**
         * Position each object in the model's grid into the center-aligned room and scale to fit in room.
         */
        internal function populate(model:Model, room:DisplayObjectContainer):void
        {
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
                var s:int = model.getShape(i);
                var c:int = model.getColor(i);
                var shapeClass:Class = shapeClasses[s];
                var cell:MovieClip = new shapeClass();
                cell.filters = filters[c];
                cell.scaleX = scale;
                cell.scaleY = scale;
                position(cell, i, model.columnCount, model.rowCount);
                room.addChild(cell);
                table.push(cell);
            }
        }

        internal function position(mc:MovieClip, i:int, columnCount:int, rowCount:int):void
        {
            var column:int = i % columnCount;
            var row:int = i / columnCount;
            mc.x = tileWidth * (0.5 + column - columnCount * 0.5);
            mc.y = tileWidth * (0.5 + row - rowCount * 0.5);
        }
    }
}
