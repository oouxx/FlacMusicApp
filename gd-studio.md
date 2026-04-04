GD Studio's Online Music Platform API
To report any unlawful activity or to protect your local authority, please contact us: gdstudio@email.com

Based on open-source projects Meting & MKOnlineMusicPlayer.

Written by metowolf & mengkun. Modded by GD Studio.

This platform is for study purposes only. Do NOT use it commercially!

免责声明：本站资源来自网络，仅限本人学习参考，严禁下载、传播或商用，如侵权请与我联系删除。继续使用将视为同意本声明

若使用本站提供的API，请注明出处“GD音乐台(music.gdstudio.xyz)”，尊重作者。使用过程如遇问题可B站私信：GD-Studio

当前稳定音乐源（动态更新）：netease、kuwo、joox、bilibili

当前访问频率限制（动态更新）：5分钟内不超50次请求

更新日期：2026-01-21

搜索
API：https://music-api.gdstudio.xyz/api.php?types=search&source=[MUSIC SOURCE]&name=[KEYWORD]&count=[PAGE LENGTH]&pages=[PAGE NUM]

source：音乐源。可选项，参数值netease（默认）、tencent、tidal、spotify、ytmusic、qobuz、joox、deezer、migu、kugou、kuwo、ximalaya、apple。部分可能失效，建议使用稳定音乐源

- 高级用法：在音乐源后加上“\_album”，如“netease_album”，可获取专辑中的曲目列表

name：关键字。必选项，关键字可以是曲目名、歌手名、专辑名

count：页面长度。可选项，一次返回显示多少内容，默认为20条

pages：页码。可选项，返回搜索结果第几页，默认为第1页

返回：id（曲目ID，即track_id）、name（歌曲名）、artist（歌手列表）、album（专辑名）、pic_id（专辑图ID）、url_id（URL ID，废弃）、lyric_id（歌词ID）、source（音乐源）

获取歌曲
API：https://music-api.gdstudio.xyz/api.php?types=url&source=[MUSIC SOURCE]&id=[TRACK ID]&br=[128/192/320/740/999]

source：音乐源。可选项，参数值netease（默认）、tencent、tidal、spotify、ytmusic、qobuz、joox、deezer、migu、kugou、kuwo、ximalaya、apple。部分可能失效，建议使用稳定音乐源

id：曲目ID。必选项，即track_id，根据音乐源不同，曲目ID的获取方式各不相同，可通过本站提供的搜索接口获取

br：音质。可选项，可选128、192、320、740、999（默认），其中740、999为无损音质

返回：url（音乐链接）、br（实际返回音质）、size（文件大小，单位为KB）

获取专辑图
API：https://music-api.gdstudio.xyz/api.php?types=pic&source=[MUSIC SOURCE]&id=[PIC ID]&size=[300/500]

source：音乐源。可选项，参数值netease（默认）、tencent、tidal、spotify、ytmusic、qobuz、joox、deezer、migu、kugou、kuwo、ximalaya、apple。部分可能失效，建议使用稳定音乐源

id：专辑图ID。必选项，专辑图ID即pic_id，可通过本站提供的搜索接口获取

size：图片尺寸。可选项，可选300（默认）、500，其中300为小图，500为大图，返回的图片不一定是300px或500px

返回：url（专辑图链接）

获取歌词
API：https://music-api.gdstudio.xyz/api.php?types=lyric&source=[MUSIC SOURCE]&id=[LYRIC ID]

source：音乐源。可选项，参数值netease（默认）、tencent、tidal、spotify、ytmusic、qobuz、joox、deezer、migu、kugou、kuwo、ximalaya、apple。部分可能失效，建议使用稳定音乐源

id：歌词ID。必选项，歌词ID即lyric_id（一般与曲目ID相同），可通过本站提供的搜索接口获取

返回：lyric（LRC格式的原语种歌词）、tlyric（LRC格式的中文翻译歌词，不一定会返回）
