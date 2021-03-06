package com.finegamedesign.facetnated
{
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.media.Sound;
    import flash.text.TextField;
    import flash.utils.getTimer;

    import org.flixel.plugin.photonstorm.API.FlxKongregate;

    public dynamic class Main extends MovieClip
    {
        [Embed(source="../../../../sfx/complete.mp3")]
        private static var completeClass:Class;
        private var complete:Sound = new completeClass();
        [Embed(source="../../../../sfx/correct.mp3")]
        private static var correctClass:Class;
        private var correct:Sound = new correctClass();
        [Embed(source="../../../../sfx/wrong.mp3")]
        private static var wrongClass:Class;
        private var wrong:Sound = new wrongClass();
        [Embed(source="../../../../sfx/contagion.mp3")]
        private static var contagionClass:Class;
        private var contagion:Sound = new contagionClass();
        [Embed(source="../../../../sfx/die.mp3")]
        private static var dieClass:Class;
        private var die:Sound = new dieClass();

        public var feedback:MovieClip;
        public var highScore_txt:TextField;
        public var level_txt:TextField;
        public var kill_txt:TextField;
        public var maxLevel_txt:TextField;
        public var maxKill_txt:TextField;
        public var room:MovieClip;
        public var score_txt:TextField;
        public var restartTrial_btn:SimpleButton;

        private var elapsed:Number;
        private var inTrial:Boolean;
        private var level:int;
        private var maxLevel:int;
        private var model:Model;
        private var previousTime:int;
        private var view:View;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }

        public function init(event:Event=null):void
        {
            inTrial = false;
            level = 1;
            maxLevel = Model.levels.length;
            previousTime = getTimer();
            elapsed = 0;
            model = new Model();
            model.onContagion = contagion.play;
            model.onDie = correct.play;
            model.onDeselect = wrong.play;
            view = new View();
            trial(level);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            level_txt.addEventListener(MouseEvent.CLICK, cheatLevel, false, 0, true);
            restartTrial_btn.addEventListener(MouseEvent.CLICK, restartTrial, false, 0, true);
        }

        private function cheatLevel(event:MouseEvent):void
        {
            level++;
            if (maxLevel < level) {
                level = 1;
            }
        }

        private function restartTrial(e:MouseEvent):void
        {
            view.clear();
            lose();
        }

        public function trial(level:int):void
        {
            inTrial = true;
            mouseChildren = true;
            model.kill = 0;
            model.maxKill = 0;
            model.populate(Model.levels[level - 1]);
            view.populate(model, room);
        }

        private function updateHudText():void
        {
            // trace("updateHudText: ", score, highScore);
            score_txt.text = model.score.toString();
            highScore_txt.text = model.highScore.toString();
            level_txt.text = level.toString();
            maxLevel_txt.text = maxLevel.toString();
            kill_txt.text = model.kill.toString();
            maxKill_txt.text = model.maxKill.toString();
        }

        private function update(event:Event):void
        {
            var now:int = getTimer();
            elapsed = (now - previousTime) * 0.001;
            previousTime = now;
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
            if (inTrial) {
                var win:int = model.update();
                view.update();
                result(win);
            }
            else {
                view.update();
                if ("next" == feedback.currentLabel) {
                    next();
                }
            }
            updateHudText();
        }

        private function result(winning:int):void
        {
            if (!inTrial) {
                return;
            }
            if (winning <= -1) {
                lose();
            }
            else if (1 <= winning) {
                win();
            }
        }

        private function win():void
        {
            inTrial = false;
            level++;
            if (Model.levels.length < level) {
                level = 0;
                feedback.gotoAndPlay("complete");
                complete.play();
            }
            else {
                feedback.gotoAndPlay("correct");
                correct.play();
            }
            FlxKongregate.api.stats.submit("Score", model.score);
        }

        private function lose():void
        {
            inTrial = false;
            FlxKongregate.api.stats.submit("Score", model.score);
            mouseChildren = false;
            feedback.gotoAndPlay("wrong");
            wrong.play();
        }

        public function next():void
        {
            feedback.gotoAndPlay("none");
            mouseChildren = true;
            if (currentFrame < totalFrames) {
                nextFrame();
            }
            if (level <= 0) {
                restart();
            }
            else {
                trial(level);
            }
        }

        public function restart():void
        {
            level = 1;
            trial(level);
            mouseChildren = true;
            gotoAndPlay(1);
        }
    }
}
