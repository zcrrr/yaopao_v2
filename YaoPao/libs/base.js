/**
 *
 * file:公共库
 * des:包含各种工具函数
 * author:ToT
 * date:2014-08-17
*/

(function($) {
	/**
	* 扩展Zepto事件绑定功能，支持PC事件
	* @param  {Sting} evtName 事件名称
	* @param  {function} fn 事件处理函数
	* @param  {Object} scope 事件处理函数作用域
	* @param  {Object} data 回传到事件处理函数的参数对象
	*/
	$.fn.onbind = function(evtName, fn, scope, data) {
		var evtName = getPlatformEventName(evtName);
		fn = fn || function() {};
		var me = $(this);
		scope = scope || me;
		me.on(evtName, function(evt) {
			fn.apply(scope, [evt, me, data]);
			return false;
		});

		//获得兼容PC事件名称
		function getPlatformEventName(evtName) {
			var evtNames = {
				"tap": "click",
				"touchstart": "mousedown",
				"touchmove": "mousemove",
				"touchend": "mouseup",
				"doubleTap": "dblclick",
				"longTap": "dblclick"
			};
			if (Base.isMobilePlatform) {
				return evtName;
			} else {
				return evtNames[evtName] || evtName;
			}
		};
	};

	$.fn.rebind = function(evtName,fn,scope,data) {
		var evtName = getPlatformEventName(evtName);
		fn = fn || function() {};
		var me = $(this);
		scope = scope || me;
		//解除绑定
		me.unbind(evtName);
		me.on(evtName, function(evt) {
			fn.apply(scope, [evt, me, data]);
			//return false;
		});

		//获得兼容PC事件名称
		function getPlatformEventName(evtName) {
			var evtNames = {
				"tap": "click",
				"touchstart": "mousedown",
				"touchmove": "mousemove",
				"touchend": "mouseup",
				"doubleTap": "dblclick",
				"longTap": "dblclick"
			};
			if (Base.isMobilePlatform) {
				return evtName;
			} else {
				return evtNames[evtName] || evtName;
			}
		};
	};
})(Zepto);


//小联网load提示
function HttpTip(obj){
	this.scope = obj.scope || this;
	this.bg = obj.bg || false;
	this.hasClose = obj.hasClose === false ? false : true;
	this.text = obj.text || "正在加载...";
	this.init.apply(this,arguments);
};
HttpTip.prototype = {
	constructor:HttpTip,
	id:"_httptip",
	closeid:"_closehttptip",
	moved:false,
	init:function(obj){
		var html = [];
		var bgcss = this.bg == true ? "" : "transparentbg";
		html.push('<div id="_httptip" class="prompt_mask ' + bgcss + '" style="display:none;">');
		html.push('<div class="p_load" >');
		html.push('<div class="loadimg"><span></span></div>');
		html.push('<div id="_httptext" class="loadtext">' + this.text + '</div>');
		if(this.hasClose){
			html.push('<div id="_closehttptip" class="loadqx"></div>');
		}
		html.push('</div></div>');
		var $tip = $("#" + this.id);
		if($tip.length == 1){
			$tip.html(html.join(''));
		}
		else{
			$(document.body).append(html.join(''));
		}
		this.bindEvent();
	},
	bindEvent:function(){
		$("#" + this.id).onbind("touchmove",this.tipMove,this);
		$("#" + this.closeid).onbind("touchstart",this.btnDown,this);
		$("#" + this.closeid).onbind("touchend",this.closeBtnUp,this);
	},
	tipMove:function(evt){
		//evt.preventDefault();
		this.moved = true;
	},
	btnDown:function(evt){
		//evt.preventDefault();
		this.moved = false;
	},
	closeBtnUp:function(evt){
		if(!this.moved){
			if(this.scope != null && this.scope != undefined){
				if(typeof this.scope.closeHttpTip == "function"){
					this.scope.closeHttpTip(evt);
				}
			}
		}
	},
	show:function(txt){
		if(txt != "" && txt != null && typeof(txt) != "undefined"){
			$("#_httptext").text(txt);
		}
		$("#_httptip").show();
	},
	hide:function(){
		$("#_httptip").hide();
	},
	isHide:function(){
		var b = true;
		var dp = $("#_httptip").css("display");
		if(dp == "block"){
			b = false;
		}
		return b;
	}
};


(function(window) {
	var global = this;
	if (typeof Base === "undefined") {
		global.Base = {}
	}
	//为什么要这么搞以下呢?
	Base.global = global;

	//正式URL端口号为21290,测试URL端口号为8008
	var UrlPort = 21290;
	//蒙版效果等待时间
	var MaskTimeOut = 1000;
	//跳转延迟
	var eventDelay = 100;
	//请求服务域名
	//var ServerUrl = "http://appservice.yaopao.net:8080/chSports";
	var ServerUrl = "http://182.92.97.144:8080/chSports";
	//手机平台
	var mobilePlatform = {
		android: /android/i.test(navigator.userAgent),
		ipad: /ipad/i.test(navigator.userAgent),
		iphone: /iphone/i.test(navigator.userAgent),
		wphone: /Windows Phone/i.test(navigator.userAgent)
	};

	//判断是否是移动平台
	var isMobilePlatform = (function() {
		return mobilePlatform.android || mobilePlatform.ipad || mobilePlatform.iphone || mobilePlatform.wphone;
	})();

	

	var emptyFn = function(){};

	/**
	* 通过元素ID查找元素对象
	* @param  {Object} elems
	* @return {Object}
	* remark:
	* 对象格式为JSON格式：{"元素ID", "元素对象"}
	*/
	function queryElemsByIds(elems) {
		if(elems){
			for (var id in elems) {
				elems[id] = $("#" + id);
			}
		}
		return elems;
	};

	/**
	* 预加载图片资源
	* @param  {Zepto} imgElem Img元素对象
	* @param  {String} imgUrl 图片资源URL
	* @param  {Object} opts 可选参数
	* opts属性：
	* success ：图片加载成功后的回调函数
	* fail ：图片加载失败后的回调函数
	* scope ：回调函数的作用域
	*/
	function imageLoaded(imgElem, imgUrl, opts) {
		if (!imgElem) {
			return;
		}
		var imgObj = new Image(),
		me = this,
		success = emptyFn,
		fail = emptyFn,
		scope = me;
		if (opts) {
			success = opts.success ? opts.success : emptyFn;
			fail = opts.fail ? opts.fail : emptyFn;
			scope = opts.scope ? opts.scope : me;
		}

		if (imgUrl) {
			imgObj.onload = function() {
				imgElem.attr("src", imgUrl);
				success.call(scope);
				imgObj.onload = null;
				imgObj.onerror = null;
				imgObj = null;
			};
			imgObj.onerror = function() {
				fail.call(scope);
				imgObj.onload = null;
				imgObj.onerror = null;
				imgObj = null;
			}
			imgObj.src = imgUrl;
		} else {
			fail.call(scope);
		}
	};

	var tout = null;
	function alertTip(msg,b){
		var box = $("#message-alert");
		if(box.length == 0){
			box = $("<div id='message-alert' class='rp_tishi' ><span>"+msg+"</span></div>");
			$(document.body).append(box);
		}
		else{
			if(b){
				box.append("<span>"+msg+"</span>");
			}
			else{
				box.html("<span>"+msg+"</span>");
			}
		}
		var dp = box.css("display");
		if(dp != "block"){
			box.show();
		}
		clearTimeout(tout);
		tout = setTimeout(function(){
			box.hide();
			box.html("");
		},3000);
	};

	/**
	* JSON对象转字符串
	* @param {JSON Object} data JSON对象
	* @return {String}
	*/
	function json2Str(obj) {
		if (obj != null || obj != undefined) {
			//console.log(obj);
			// var strs = ['{'];
			// for (var k in data) {
			//     strs.push('"' + k + '":"' + (data[k] || null) + '",')
			// }
			// var str = strs.join("");
			// return str.substr(0, str.length - 1) + '}';
			switch (typeof(obj)) {
				case 'string':
					return '"' + obj.replace(/(["\\])/g, '\\$1') + '"';
				case 'array':
					return '[' + obj.map(json2Str).join(',') + ']';
				case 'object':
					if (obj instanceof Array) {
						var strArr = [];
						var len = obj.length;
						for (var i = 0; i < len; i++) {
							strArr.push(json2Str(obj[i]));
						}
						return '[' + strArr.join(',') + ']';
					} else if (obj == null) {
						//return 'null';  
						return 'null';
						//return 'abc';
					} else {
						var string = [];
						for (var property in obj) {
							var objVal = json2Str(obj[property]);
							if (objVal == undefined) {
								objVal = '\"\"';
								//objVal = null;
							}
							string.push(json2Str(property) + ':' + objVal);
						}
						return '{' + string.join(',') + '}';
					}
				case 'number':
					return obj;
				case false:
					return obj;
			}
		}
	};

	/**
	* JSON对象字符串转化为JSON对象
	* @param  {String} data
	* @return {JSON Object}
	*/
	function str2Json(data) {
		if (data) {
			try{
				return $.parseJSON(data);
			}
			catch(e){
				return null;
			}
		}
	};

	/**
	* Http请求参数数据对象转换成字符串
	* @param  {JSON Object} data
	*/
	function httpData2Str(data) {
		var strs = ["?"];
		if (data) {
			for (var key in data) {
				strs.push(key + "=" + data[key] + "&");
			}
		}
		var timer = "callback=?&timer=" + getDateTime();
		strs.push(timer);
		return strs.join("");
	};

	/**
	* 返回毫秒级时间戳
	* @return {Int}
	*/
	function getDateTime() {
		return new Date().getTime();
	};

	/*
	$(window).on("touchstart", function(evt) {
		if (httpTip.isOpened) {
			evt.preventDefault();
		}
	});
	*/

	var localStore = window.localStorage;
	var undefinedType = void 0;
	var isEnableStore = "localStorage" in window && localStore !== null && localStore !== undefinedType;

	//离线存储控制器
	var offlineStore = {
		_isEnableStore_: isEnableStore,
		/**
		* 离线存储某值
		* @param {String} key 存储的值索引
		* @param {String} value 存储的值
		* @isSession{Boolean} 是否永久保存
		* @private
		*/
		set: function(key, value,isSession) {
			if (isEnableStore) {
				//删除本地以前存储的JS模块信息，先removeItem后setItem防止在iphone浏览器上报错
				for (var name = key, len = localStore.length, id; len--;) {
					id = localStore.key(len);
					- 1 < id.indexOf(name) && localStore.removeItem(id);
				}
				try {
					if(isSession){
						sessionStorage.setItem(key,value);
					}
					else{
						localStore.setItem(key, value);
					}
				} catch (error) {
					localStore.clear();
				}
			}
		},
		//清楚本地缓存
		remove: function(key,isSession){
			if(isSession){
				//历史保存
				sessionStorage.removeItem(key);
			}
			else{
				localStore.removeItem(key);
			}
		},
		/**
		* 根据关键字获取某值
		* @param {String} key 关键字
		* @return {*}
		* @private
		*/
		get: function(key,isSession) {
			if(isSession){
				return sessionStorage.getItem(key) || "";
			}
			else{
				return isEnableStore && this.isExist(key) ? localStore.getItem(key) : "";
			}
		},
		/**
		* 根据关键字判断是否有本地存储
		* @param {String} key 关键字
		* @return {Boolean}
		* @private
		*/
		isExist: function(key) {
			return isEnableStore && !! localStore[key];
		}
	};

	/**
	* 从本地存储获取用户信息对象
	*
	* {
	"username": "傲梅雪舞", //用户昵称
	"avatar": "http://mobile.trafficeye.com.cn/media/test/avatars/22376/image.jpg", //用户头像图片
	"gender": "F", //用户性别
	"usertype": "1", //用户类型
	"friends_count": "4", //用户关注数量
	"followers_count": "0", //用户粉丝数量
	"uid": 22376, //用户ID
	"pid": 353617052835307 //用户PID
	}
	*/
	function getLocalInfo() {
		var myInfoStr = offlineStore.get("_localuserinfo");
		return str2Json(myInfoStr);
	};

	//判断URL是否存在
	function pageUrlIndex(url){
		var pageUrl = offlineStore.get("web_pageurl",true) || "";
		if(pageUrl == ""){
			pageUrl = [];
		}
		else{
			pageUrl = str2Json(pageUrl);
		}
		var index = pageUrl.indexOf(url);
		if(index == -1){
			//页面没有加载过
			pageUrl.unshift(url);
			var jsonStr = json2Str(pageUrl);
			offlineStore.set("web_pageurl",jsonStr,true);
			//标识load页面
			return 99;
		}
		return index == 0 ? 0 : -index;
	};

	//返回
	function pageBack(index){
		var i = index;
		var pageUrl = offlineStore.get("web_pageurl",true) || "";
		if(pageUrl == ""){
			pageUrl = [];
		}
		else{
			pageUrl = str2Json(pageUrl);
		}
		while(i < 0){
			pageUrl.shift();
			i++;
		}
		var jsonStr = json2Str(pageUrl);
		offlineStore.set("web_pageurl",jsonStr,true);
		history.go(index);
	};

	/**
	* 跳转页面
	* @param  {[type]} url [description]
	* @return {[type]}     [description]
	*/
	function toPage(url) {
		if (url) {
			//判断URL栈,判断是否有历史页面
			var index = pageUrlIndex(url);
			if(index == 99){
				setTimeout(function() {
				window.location.href = url;
				}, 1);
			}
			else{
				pageBack(index);
			}
		}
	};

	
	//Trafficeye.PageNumManager = PageNumManager;
	//Trafficeye.reqPraiseServer = reqPraiseServer;
	//Trafficeye.fromSource = fromSource;
	//Base.httpTip = httpTip;

	Base.page = null;
	Base.UrlPort = UrlPort;
	Base.MaskTimeOut = MaskTimeOut;
	Base.ServerUrl = ServerUrl;
	Base.delay = eventDelay;

	Base.mobilePlatform = mobilePlatform;
	Base.isMobilePlatform = isMobilePlatform;

	Base.alert = alertTip;
	Base.imageLoaded = imageLoaded;
	Base.queryElemsByIds = queryElemsByIds;
	Base.getDateTime = getDateTime;

	Base.httpData2Str = httpData2Str;
	Base.offlineStore = offlineStore;
	Base.getLocalDataInfo = getLocalInfo;

	Base.json2Str = json2Str;
	Base.str2Json = str2Json;
	
	Base.toPage = toPage;
	Base.pageBack = pageBack;
	
}(window));






/*
    function PageNumManager() {
        //分页起始条目
        this.start = 0;
        //每页显示个数
        this.BASE_NUM = 10;
        //微博界面显示个数
        this.BASE_WEIBO_NUM = 50;
        //是否显示加载更多按钮
        this.isShowBtn = false;
    };
    PageNumManager.prototype = {
        reset: function() {
            this.start = 0;
            this.isShowBtn = false;
        },
        getStart: function() {
            return this.start;
        },
        getEnd: function() {
            return this.BASE_NUM + this.start - 1;
        },
        getWeiboEnd: function() {
            return this.BASE_WEIBO_NUM + this.start - 1;
        },
        setIsShowBtn: function(flag) {
            this.isShowBtn = flag;
        },
        getIsShowBtn: function() {
            return this.isShowBtn;
        }
    };

    function reqPraiseServer(uid, friendid, publishid, pid, reqType) {

        var BASE_URL = "http://mobile.trafficeye.com.cn:"+this.UrlPort+"/TrafficeyeCommunityService/sns/v1/praise";
        var data = {
            "uid": uid,
            "friend_id": friendid,
            "publish_id": publishid,
            "type": "event",
            "pid": pid,
            "requestType": reqType
        };
        var reqParams = httpData2Str(data);
        var reqUrl = BASE_URL + reqParams;
        $.ajaxJSONP({
            url: reqUrl,
            success: function(data) {

            }
        })
    };
*/