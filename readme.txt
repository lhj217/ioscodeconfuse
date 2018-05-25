# 本程序现在能修改 objective-c he C++, C#已实现但没有测试
配置 config.plist
<dict>
	<!--是否混淆 CPP 文件-->
	<key>isConfuseCpp</key>
	<true/>
	<!--是否混淆 OC 文件-->
	<key>isConfuseObjc</key>
	<true/>
	<!--是增加CPP垃圾文件-->
	<key>isInsertGarbageForCppFile</key>
	<true/>
	<!--是增加OC垃圾文件-->
	<key>isInsertGarbageForObjcFile</key>
	<true/>
	<!--源代码位置-->
	<key>sourcePath</key>
	<array>
		<string>/Volumes/data/tool/game/popstar_ios/Classes</string>
		<string>/Volumes/data/tool/game/popstar_ios/proj.ios_mac</string>
	</array>
	<!--文件输出路径-->
	<key>outputDir</key>
	<string>/Volumes/data/tool/game/popstar_ios/Classes</string>
	<!--排除文件，可以是目录名和文件名-->
	<key>excludeName</key>
	<array>
		<string>Carthage</string>
		<string>Pods</string>
		<string>garbagecode</string>
	</array>
	<!--生成垃圾文件的比例，假如现在有200个文件，如果比例设置为70，那么就会生成140个新文件 -->
	<key>garbageFilePercent</key>
	<integer>100</integer>
	<!--生成垃圾代码的比例，垃圾文件是在{后面插入，如果一个文件有100个{}块，比例设置为70，那么只有70个{}里会生成垃圾文件-->
	<key>garbageCodePercent</key>
	<integer>100</integer>
</dict>
</plist>

