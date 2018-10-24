// @codekit-prepend "init-foundation.js", "tinypubsub.js", "velocity.js", "velocity.ui.js", "scrollmagic/uncompressed/ScrollMagic.js", "scrollmagic/uncompressed/plugins/animation.gsap.js", "odometer.js";


/*!
 * Glance Digital Custom JavaScript Programing
 * lance@glance.ca
 *
 */

jQuery(document).ready(function($) {


    // SETTINGS
    // ------------------

    // Odometer Options
    // ------

    window.odometerOptions = {
        duration: 1200
    }

    // Velocty Easing
    // ------

    $.Velocity.defaults.easing = 'easeInOutQuart';




    // BROWSERS AND SUPPORT
    // ------------------
    
    // Touch device 
    // ------

    var is_touch_device = 'ontouchstart' in document.documentElement;

    if (is_touch_device) {
        $('body').addClass('touchDevice');
    }

    // var iOS = /(iPad|iPhone|iPod)/g.test(navigator.userAgent);
    // if (iOS) {
    //     $('body').addClass('iOS');
    // }
    var is_android = /(android)/i.test(navigator.userAgent);
    if (is_android) {
        $('body').addClass('is-android');
    }

    // Blend Mode Detection
    // ------
    
    var supports_background_blend_mode = window.getComputedStyle(document.body).backgroundBlendMode;

    if (!supports_background_blend_mode) {
        $('body').addClass('no_blendmode');
    }

    $('body').addClass('ready');



    // PLUGINS
    // ------------------

    if ($('.snowball-throw-styles').length) {
        $('.snowball-throw-styles').snowballThrowStyleSelector();
    } else if ($('#facebook-share').length) {
        $('#facebook-share').simpleShare();
    }

    if ($('.bcchf_snowball_page').length) {
        $('.bcchf_snowball_page').snowballLanding({is_android: is_android});
    }
    if ($('.bcchf_thankyou_page').length) {
        $('.bcchf_thankyou_page').snowballIntro({intro_frames: 10, fg_frames: 20, total_frames: 20, is_android: is_android});
    }

    if ($('.throwCount').length) {
        $('.throwCount').throwCounter();
    }

});




// ------------------------------------------------------------------------------------------------------------------------------------------------
// PLUGINS


(function($) {



    // Snowball Throw Style Selector
    // ------

    $.fn.simpleShare = function(options) {
        var settings = $.extend({}, options);

        var $share_button = $('#facebook-share');
        var id = $share_button.data('share');
        
        $share_button.on('click', function() {
            fbShare(id);
        });

        function fbShare(id, options) {
            var settings = $.extend({
                winWidth: 600,
                winHeight: 450 
            }, options);

            var winTop = (screen.height / 2) - (settings.winHeight / 2);
            var winLeft = (screen.width / 2) - (settings.winWidth / 2);
            window.open('https://www.facebook.com/sharer/sharer.php?u='+ encodeURIComponent(id) +'&amp;src=sdkpreparse', 'sharer', 'top=' + winTop + ',left=' + winLeft + ',toolbar=0,status=0,width='+settings.winWidth+',height='+settings.winHeight);
        }
    }

    $.fn.snowballThrowStyleSelector = function() {

        var $container = this;
        var $videos = $container.find('video');
        var $styles = $container.find('a');
        var $share_button = $('#facebook-share');
        var id = $styles.first().data('share');

        // auto play selected previews
        $styles.filter('.selected').find('video').get(0).play();

        $styles.on('click', function(e) {
            e.preventDefault();
            var $this = $(this);
            var $video = $this.find('video').get(0);
            var $indicator = $this.find('.indicator');
            var state = $this.data('state');

            id = $this.data('share');

            $videos.each(function() {
                var $v = $(this).get(0);
                $v.pause();
                $v.currentTime = 0;
            });

            $styles.data('state', '').removeClass('selected');

            if (state != 'selected') {
                $this.data('state', 'selected').addClass('selected');
                $video.play();
            }
        });

        $share_button.on('click', function() {
            fbShare(id);
        });

        return this;
    }

    function fbShare(id, options) {
        var settings = $.extend({
            winWidth: 600,
            winHeight: 450 
        }, options);

        var winTop = (screen.height / 2) - (settings.winHeight / 2);
        var winLeft = (screen.width / 2) - (settings.winWidth / 2);
        window.open('https://www.facebook.com/sharer/sharer.php?u='+ encodeURIComponent(id) +'&amp;src=sdkpreparse', 'sharer', 'top=' + winTop + ',left=' + winLeft + ',toolbar=0,status=0,width='+settings.winWidth+',height='+settings.winHeight);
    }



    // Snowball landing animation
    // ------

    $.fn.snowballIntro = function(options) {
        var settings = $.extend({
            intro_frames: 10,
            fg_frames: 20,
            total_frames: 144,
            is_android: false
        }, options);
        var $html = $('html');
        var $window = $(window);
        var $container = this;
        var $frames = $container.find('#slides-fg div, #slides div');
        var $bg_frames = $container.find('#slides div');
        var $fg_frames = $container.find('#slides-fg div');
        var intro_frames = settings.intro_frames;
        var fg_frames = settings.fg_frames;
        var total_frames = settings.total_frames;
        var controller = new ScrollMagic.Controller();
        var obj = {curImg: 0};
        var desktop = Foundation.MediaQuery.atLeast('medium');

        var intro_tween = TweenMax.to(obj, .9,
            {
                curImg: intro_frames, // animate propery curImg to number of images
                roundProps: "curImg", // only integers so it can be used as an array index
                immediateRender: true, // load first image automatically
                ease: Linear.easeNone,
                onUpdate: function () {
                    $bg_frames.css({visibility: 'hidden'}).eq(obj.curImg).css({visibility: 'visible'});
                    $fg_frames.css({visibility: 'hidden'}).eq(obj.curImg).css({visibility: 'visible'});
                }
            }
        );

        function update_view(event, name) {
            desktop = Foundation.MediaQuery.atLeast('medium');
        }
        $(window).on('changed.zf.mediaquery', update_view);

        var intro_frames_scene = new ScrollMagic.Scene({offset: 0})
            .setTween(intro_tween);

        var scroll_frames_scene = new ScrollMagic.Scene({offset: 0, duration: '75%'})
            .on("progress", function (e) {
                scroll_prog(e.progress);
            });

        function scroll_prog(prog) {
            var id = intro_frames;
            if (prog > 1) {
                id = total_frames;
            } else if (prog > 0) {
                id = Math.floor(prog * (total_frames - intro_frames)) + intro_frames;
            }
            $bg_frames.css({visibility: 'hidden'}).eq(id).css({visibility: 'visible'});
            $fg_frames.css({visibility: 'hidden'});
            if (prog < fg_frames/total_frames) {
                $fg_frames.eq(id).css({visibility: 'visible'});
            }
        }

        var preload = [];
        var promises = [];
        var $preload_bg = $bg_frames.slice(0,intro_frames);
        var $preload_fg = $fg_frames.slice(0,intro_frames);
        var $preload_frames = settings.is_android ? $.fn.add.call($preload_bg,$preload_fg) : $frames;
        $preload_frames.each(function(i) {
            var style = $(this).attr('style');
            var start = style.indexOf('url(') + 4;
            var end = style.indexOf(');');
            preload[i] = style.substring(start, end).replace(/^\"+|\"+$/g, '');
        });
        
        for (var i = 0; i < preload.length; i++) {
            (function(url, promise) {
                var img = new Image();
                img.onload = function() {
                  promise.resolve();
                };
                img.src = url;
            })(preload[i], promises[i] = $.Deferred());
        }
        $.when.apply($, promises).done(function() {
            
            setTimeout(function() {
                $container.addClass('preloaded');
            }, 300);

            if (!settings.is_android) {
                setTimeout(function() {

                    controller.addScene([
                        scroll_frames_scene,
                    ]);         

                }, 450);
            }
            
            setTimeout(startIntro, 900);
        });        
        

        function startIntro() {
            var pageHeight = $window.height() * 5;
            controller.addScene([intro_frames_scene]);
        }

        return this;
    }



    $.fn.snowballLanding = function(options) {
        var settings = $.extend({
            intro_frames: 10,
            fg_frames: 20,
            total_frames: 144,
            is_android: false
        }, options);
        var $html = $('html');
        var $window = $(window);
        var $container = this;
        var $screen_container = $('#screen_h');
        var $frames = $container.find('#slides-fg div, #slides div');
        var $bg_frames = $container.find('#slides div');
        var $fg_frames = $container.find('#slides-fg div');
        var $screens = $container.find('.screen');
        var $cta = $('#cta');
        var $triggers = $('.screen-trigger');
        var intro_frames = settings.intro_frames;
        var fg_frames = settings.fg_frames;
        var total_frames = settings.total_frames;
        var controller = new ScrollMagic.Controller();
        var obj = {curImg: 0};
        var desktop = Foundation.MediaQuery.atLeast('medium');
        var $header = $('.site-header');
        var $nav = $('#screen-nav a');

        var intro_tween = TweenMax.to(obj, .9,
            {
                curImg: intro_frames, // animate propery curImg to number of images
                roundProps: "curImg", // only integers so it can be used as an array index
                immediateRender: true, // load first image automatically
                ease: Linear.easeNone,
                onUpdate: function () {
                    $bg_frames.css({visibility: 'hidden'}).eq(obj.curImg).css({visibility: 'visible'});
                    $fg_frames.css({visibility: 'hidden'}).eq(obj.curImg).css({visibility: 'visible'});
                }
            }
        );

        function update_view(event, name) {
            desktop = Foundation.MediaQuery.atLeast('medium');
        }
        $(window).on('changed.zf.mediaquery', update_view);

        var intro_frames_scene = new ScrollMagic.Scene({offset: 0})
            .setTween(intro_tween);

        var scroll_frames_scene = new ScrollMagic.Scene({offset: 0, duration: '400%'})
            .on("progress", function (e) {
                scroll_prog(e.progress);
            });

        var msg_1_out = new ScrollMagic.Scene({triggerElement: "#screen-1-trigger-out"})
            .on('start', function(e) {
                var fwd = e.scrollDirection === "FORWARD";
                if (fwd) {
                    TweenMax.to($screen_container, .9, {top:'-100vh', ease: Cubic.easeInOut});
                    $header.addClass('hidden');

                } else {
                    TweenMax.to($screen_container, .9, {top:'0', ease: Cubic.easeInOut});
                    $header.removeClass('hidden');
                }
            });
            
        var msg_2_out = new ScrollMagic.Scene({triggerElement: "#screen-2-trigger-out"})
            .on('start', function(e) {
                var fwd = e.scrollDirection === "FORWARD";
                if (fwd) {
                    TweenMax.to($screen_container, .9, {top:'-200vh', ease: Cubic.easeInOut});
                } else {
                    TweenMax.to($screen_container, .9, {top:'-100vh', ease: Cubic.easeInOut});
                }
            });

        var msg_3_out = new ScrollMagic.Scene({triggerElement: "#screen-3-trigger-out"})
            .on('start', function(e) {
                var fwd = e.scrollDirection === "FORWARD";
                if (fwd) {
                    TweenMax.to($screen_container, .9, {top:'-300vh', ease: Cubic.easeInOut});
                } else {
                    TweenMax.to($screen_container, .9, {top:'-200vh', ease: Cubic.easeInOut});
                }
            });

        var msg_4_out = new ScrollMagic.Scene({triggerElement: "#screen-4-trigger-out"})
            .on('start', function(e) {
                var fwd = e.scrollDirection === "FORWARD";
                if (fwd) {
                    TweenMax.to($screen_container, .9, {top:'-400vh', ease: Cubic.easeInOut});
                } else {
                    TweenMax.to($screen_container, .9, {top:'-300vh', ease: Cubic.easeInOut});
                }
            });

        function scroll_prog(prog) {
            var id = intro_frames;
            if (prog > 1) {
                id = total_frames;
            } else if (prog > 0) {
                id = Math.floor(prog * (total_frames - intro_frames)) + intro_frames;
            }
            $bg_frames.css({visibility: 'hidden'}).eq(id).css({visibility: 'visible'});
            $fg_frames.css({visibility: 'hidden'});
            if (prog < fg_frames/total_frames) {
                $fg_frames.eq(id).css({visibility: 'visible'});
            }
        }


        var preload = [];
        var promises = [];
        var $preload_bg = $bg_frames.slice(0,intro_frames);
        var $preload_fg = $fg_frames.slice(0,intro_frames);
        var $preload_frames = settings.is_android ? $.fn.add.call($preload_bg,$preload_fg) : $frames;
        $preload_frames.each(function(i) {
            var style = $(this).attr('style');
            var start = style.indexOf('url(') + 4;
            var end = style.indexOf(');');
            preload[i] = style.substring(start, end).replace(/^\"+|\"+$/g, '');
        });
        
        for (var i = 0; i < preload.length; i++) {
            (function(url, promise) {
                var img = new Image();
                img.onload = function() {
                  promise.resolve();
                };
                img.src = url;
            })(preload[i], promises[i] = $.Deferred());
        }
        $.when.apply($, promises).done(function() {
            
            setTimeout(function() {
                $container.addClass('preloaded');
            }, 300);
            
            if (!settings.is_android) {
                setTimeout(function() {

                    controller.addScene([
                        scroll_frames_scene,
                        msg_1_out,
                        msg_2_out,
                        msg_3_out,
                        msg_4_out,
                    ]);         

                }, 450);
            }

            setTimeout(startIntro, 900);
        });        
        

        function startIntro() {
            var pageHeight = $window.height() * 5;
            // $html.velocity('scroll', {duration: 1000, offset: Math.ceil(pageHeight * (intro_frames/total_frames)), easing: "linear"});
            controller.addScene([intro_frames_scene]);
        }

        $cta.on('click', function() {
            $triggers.each(function() {
                var $this = $(this);
                if (belowFocus($this, .5)) {
                    $html.velocity('scroll', {duration: 1700, offset: $this.offset().top, easing: "linear"});
                    return false;
                }
            });
        });


        var $last_trigger = $triggers.last();
        $window.on('scroll', function() {
            var trigger = false;

            if (!belowFocus($last_trigger, .5)) {
                $cta.addClass('done');
            } else {
                $cta.removeClass('done');
            }
            
            $triggers.each(function(e) {
                if (belowFocus($(this), .5)) {
                    $nav.removeClass('selected').eq(e).addClass('selected');
                    trigger = true;
                    return false;
                }
            });
            
            if (!trigger) {
                $nav.removeClass('selected').last().addClass('selected');
            }
        });

        $nav.on('click', function(e) {
            e.preventDefault();
            var $targ = $($(this).attr('href'));
            $html.velocity('scroll', {duration: 1700, offset: $targ.offset().top, easing: "linear"});
        });


        return this;
    }



    // Throw Counter
    // ------
    $.fn.throwCounter = function() {
        var $num = this;

        setTimeout(function() {
            $num.html($num.data('value'));    
        }, 1800);

        return this;
    }




    // Utilities
    // ------

    aboveView = function(element) {
        return $(window).scrollTop() >= element.offset().top + element.outerHeight();
    }

    belowFocus = function(element, focusMultipliers) {
        return $(window).height() + $(window).scrollTop() < element.offset().top + $(window).height() * focusMultipliers;
    }
    
    isInFocus = function(element, focusMultipliers) {
        return (aboveView(element)!=true && belowFocus(element, focusMultipliers)!=true);
    }


})(jQuery);