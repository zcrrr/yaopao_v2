/**
 * <pre>
 * UserInfoManager登录信息管理
 * PageManager页面功能管理
 * </pre>
 *
 * file:修改跑队密码
 * author:ToT
 * date:2014-08-19
*/

var PageManager = function (obj){
	//继承父类 公用事件
	//TirosBase.apply(this,arguments);
	//继承父类 公用函数
	//TirosTools.apply(this,arguments);
	this.init.apply(this,arguments);
};


PageManager.prototype = {
	constructor:PageManager,
	iScrollX:null,
	httpId:null,
	//页面宽度
	bodyWidth:0,
	//队员数据
	memberData:null,
	init: function(){
		this.httpTip = new HttpTip({scope:this});
		//$(window).onbind("load",this.pageLoad,this);
		$(window).onbind("touchmove",this.pageMove,this);
		this.bindEvent();
	},
	bindEvent:function(){
		//返回按钮事件
		$("#backBtn").onbind("touchstart",this.btnDown,this);
		$("#backBtn").onbind("touchend",this.pageBack,this);

		//离开文本框事件
		$("#newPwd").onbind("blur",this.newPwdBlur,this);

		//修改密码
		$("#updatePwdBtn").onbind("touchstart",this.btnDown,this);
		$("#updatePwdBtn").onbind("touchend",this.updatePwdBtnUp,this);
		
	},
	pageLoad:function(evt){
		var w = $(window).width();
		var h = $(window).height();
		//this.ratio = window.devicePixelRatio || 1;
		this.bodyWidth = w;

	},
	pageBack:function(evt){
		Base.pageBack(-1);
	},
	pageMove:function(evt){
		this.moved = true;
	},
	
	/**
	 * 隐藏dom 卸载资源
	*/
	pageHide:function(){
	},
	
	btnDown:function(evt){
		//按钮按下通用高亮效果
		this.moved = false;
		var ele = evt.currentTarget;
		$(ele).addClass("curr");
	},

	/*
	 * 离开新密码文件框验证密码
	*/
	newPwdBlur:function(evt){
		var newPwd = $("#newPwd");
		var pwd = newPwd.val();
		var reg = /^([0-9]|[a-z]|[A-Z]){6,16}$/;
		if(!reg.test(pwd)){
			Base.alert("新密码格式错误!");
			newPwd[0].focus();
		}
	},

	/*
	 * 修改密码
	*/
	updatePwdBtnUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			//修改密码
			var oldPwd = $("#oldPwd").val();
			var newPwd = $("#newPwd").val();
			var reg = /^([0-9]|[a-z]|[A-Z]){6,16}$/;
			if(reg.test(newPwd)){
				this.setTeamNewPwd(oldPwd,newPwd);
			}
			else{
				Base.alert("新密码格式错误!");
			}
		}
		else{
			$(ele).removeClass("curr");
		}
	},

	/**
	 * 初始化滚动插件
	*/
	initiScroll:function(){
	},
	
	/*
	 * 修改密码
	*/
	setTeamNewPwd:function(oldPwd,newPwd){
		var options = {};
		//上报类型 1 手机端 2网站
		options.stype = 1;
		//用户ID
		options.uid = "132";
		//组ID
		options.gid = 7;
		//比赛id,现在只有一个比赛 值=1
		options.mid = 1;
		//客户端唯一标识
		options["X-PID"] = "tre211";
		
		var reqUrl = this.bulidSendUrl("/match/changepassword.htm",options);
		//console.log(reqUrl);
		this.httpTip.show();
		$.ajaxJSONP({
			url:reqUrl,
			context:this,
			success:function(data){
				//console.log(data);
				var state = data.state.code - 0;
				if(state === 0){
					this.memberData = data;
					this.changeMemberHtml(data);
				}
				else{
					var msg = data.state.desc + "(" + state + ")";
					Base.alert(msg);
				}
				this.httpTip.hide();
			}
		});
	},

	/**
	 * 生成请求地址
	 * server请求服务
	 * options请求参数
	*/
	bulidSendUrl:function(server,options){
		var serverUrl = Base.offlineStore.get("local_server_url",true) + "chSports";
		var url = serverUrl + server;
		
		var data = {};
		/*
		//个人信息
		var myInfo = Trafficeye.getMyInfo();
		var data = {
			"ua":myInfo.ua,
			"pid":myInfo.pid,
			"uid":myInfo.uid,
			"lon":this.lon,
			"lat":this.lat
		};
		*/
		//添加服务参数
		for(var k in options){
			data[k] = options[k];
		}
		//格式化请求参数
		var reqParams = Base.httpData2Str(data);
		var reqUrl = url + reqParams;
		return reqUrl;
	},


	/**
	 * 关闭提示框
	*/
	closeTipBtnUp:function(evt){
		if(evt != null){
			var ele = evt.currentTarget;
			$(ele).removeClass("curr");
			if(!this.moved){
			}
		}
		else{
		}
	},
	
	/**
	 * 重试
	*/
	retryBtnUp:function(evt){
		var ele = evt.currentTarget;
		$(ele).removeClass("curr");
		if(!this.moved){
		}
	},
	
	/**
	 * 关闭http提示框,中断http请求
	*/
	closeHttpTip:function(){
		this.httpTip.hide();
		this.pageHide();
	}
};

//页面初始化
$(function(){
	Base.page = new PageManager({});
});



