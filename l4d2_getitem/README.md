安全区域按E+R刷取近战，修改提示为静默，即玩家获取近战，离开安全区域、安全区域外按e+r均不会在聊天框提示了，参考了l4d_start_safe_area中的安全区域检测逻辑，l4d_start_safe_area在某些（烂）三方图中提供了可靠的安全区域避免生还者在开场动画中被生成的特感攻击，玩家也可以在该区域中使用l4d2_getitem插件，因为这些三方图开局安全区域判定不一，所以有了此想法

left4dead2/addons/sourcemod/data/l4d_start_safe_area.cfg





l4d2_getitem作者地址：https://steamcommunity.com/profiles/76561198100717207/



参考的l4d_start_safe_area：[L4D1_2-Plugins/l4d_start_safe_area at master · fbef0102/L4D1_2-Plugins](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_start_safe_area)