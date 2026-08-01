CoolMathGamesCriteria:

The following is an email from Cool Math Games about licensing this game. It was seent 7/28/2026. I want to meet the criteria layed out in the email and the instructions

"Hi Tanner,

Thank you for your response; I'm happy to hear you're interested!

Here are our details for licensing:
Remove any external links, visible .com web address or analytics tracking
Add our splash screen to the start of the game (see PNG attached below)
Add our API integrations (see attached for more details - mention if midroll/rewarded/no ads are better)
Remove any blood/gore or adult themed content
Make sure the game fits within our iFrame which is a maximum of 800px wide and 600 px tall. It doesn’t have to be in that ratio, just within those boundaries.
Remove any full screen buttons or functionality
I also have a few suggestions to help improve the game for Coolmath Games:
When viewing the upgrades after completing a round, please grey out any upgrades the player cannot afford to visually indicate this.
This is more of an idea: Would you be able to add more weeks in the game? Perhaps the full game could be extended to 10 weeks?
The process is that after you have made those changes, please send me the zip file of the game and I'll test it on our site across different browsers. As long as everything works there, we provide payment either through PayPal or wire transfer.

Given that list of changes, how much would you charge for the non-exclusive license?

Please let me know your thoughts and if you have any questions. I look forward to working with you!

Best regards,
Antonia"

Game Instructions for CoolMathGames:
"Instructions
1. Please show our splash screen on game load (no need to remove your logos) – you can show them
before or after our splash screen.
2. Please do NOT make our splash screen clickable.
3. We will need some images from your game to create the game page on our site. Please send us the
following images:
a. Square image – this is a square image of your game of at least 200x200 resolution, JPEG or
PNG. It doesn’t need to have your game name. If your game has a main character or a key
game design element, please try to feature it here. Example: if your game is Pac-man, good
to have Pac-man in this image.
b. Game logo with transparent background – PNG format. This should be medium to hi-res.
4. Please set the tab name to “Game Name – Play it now at CoolmathGames.com” where Game Name
is the name of your game.
5. Please optimize the file size of the game where possible. Ideally it will be under 50mb, but smaller is
always preferred.
6. We don’t need a “more games” button. If you have one, please remove it.
7. If you have a full screen button in your game, please remove that also.
8. If your game has a high score leaderboard where users enter their name/initials, please remove it.
9. Please ensure that your game is framerate-independent, meaning it should play identically on 60hz
and on high-refresh rate monitors (120hz, 144hz, 165hz, etc.)
10. Please have no stat counters or analytics in the game.
11. Also, please remove any external links, email addresses, website addresses, or twitter handles from
the credits page (or any other page), if there are any.
12. Please make sure the game uses adaptive scaling to fit different device sizes. It must also fit within a
maximum of 800px wide and 600px high for our website’s iframe.
13. Safari has added (and we expect Chrome will as well) a new option, enabled by default, that blocks
audio from autoplaying elements on the page. Please ensure that this does not happen to your
game. To see this option for yourself in safari you go to Safari menu &gt; Preferences &gt; Websites Tab &gt;
Auto-Play &gt; and the look for the website – the setting should be next to it.
a. It seems like the best way to avoid the audio being blocked is to add some sort of play
button that the player will press before the game tries to play sound, if there is not one
already.

14. Please make sure that progress saves to local storage or indexed DB so players can continue in a new
play session in the same browser.
If your game works on Mobile Web:
1. On Android, if you have “Add GAMENAME to Home screen” functionality when the game starts up,
please remove it.
2. Please ensure that your game’s mobile controls still work in Safari on iPad OS (iPad with iOS 13+). If
the browser is safari and touch events are enabled, make sure you are showing your on-screen
mobile controls (if there are any). You can look for ‘ontouchend’ in the document in Safari using
userAgent:window.navigator.userAgent.indexOf(“Safari”) &gt;=0

API
We have a custom JavaScript event system on our site which make sure that ad refreshes are triggered in
between levels, rather than during gameplay, where it would negatively affect the user experience. One API

triggers display ad refresh, and the other is used for midroll ads. The display ads should always be called
whenever the player starts a new level or restarts a level.
GAME EVENTS
Here are the game events and JavaScript functions to add:
The Play button at game start (if applicable):
window.parent.postMessage({&#39;cm_game_event&#39;: true, &#39;cm_game_evt&#39; : &#39;start&#39;, &#39;cm_game_lvl&#39;: 0},
&#39;*&#39;);
Starting a level
window.parent.postMessage({&#39;cm_game_event&#39;: true, &#39;cm_game_evt&#39; : &#39;start&#39;, &#39;cm_game_lvl&#39;:
level}, &#39;*&#39;);
Replaying a level
window.parent.postMessage({&#39;cm_game_event&#39;: true, &#39;cm_game_evt&#39; : &#39;replay&#39;, &#39;cm_game_lvl&#39;:
level}, &#39;*&#39;);

MIDROLL AND REWARDED AD EVENTS
The second API, cmgAdBreak(), is used to refresh our midroll ads. cmgRewardAds() is used to trigger a
rewarded ad. Generally this should be called at a convenient time for the player, for example after you beat a
level, right after you press the button to start the next level. If you are not sure the best time to call the
function, please ask us.

Include the following js files in the footer of your game’s index.html:
If the game does not include jQuery then include the following script.
&lt;script src=&quot;https://ajax.googleapis.com/ajax/libs/jquery/3.6.3/jquery.min.js&quot;&gt;&lt;/script&gt;
&lt;script type=&quot;text/javascript&quot; src=&quot;https://www.coolmathgames.com/sites/default/files/cmg-
ads.js&quot;&gt;&lt;/script&gt;
When you want to trigger the Ad call this function:
//call the function from the included JS code
For midroll ads: cmgAdBreak()
For rewarded ads: cmgRewardAds()
Add the following event listeners (adBreakStart and adBreakComplete) :
&lt;script&gt;
// To trigger the event Listener adBreakStart
document.addEventListener(&quot;adBreakStart&quot;, () =&gt; {
console.log(&quot;AdBreak Started&quot;)
//TODO: Developer needs to add the logic to pause the game and sound here
});
// To trigger the event Listener adBreakComplete

document.addEventListener(&quot;adBreakComplete&quot;, () =&gt; {
console.log(&quot;adBreak Complete&quot;)
//TODO: Developer needs to add the logic to resume the game and sound here
});
&lt;/script&gt;
In adBreakStart event listener, game developer can do the following tasks:
Pause the Sound
Pause the scene / Load the levels screen etc
In adBreakComplete event listener, game developer can do the following tasks:
Resume the sound
Resume the scene / start the next level etc
NOTE: We will decide how often to run ads on our side, so not every cmgAdBreak will result in an ad
showing up. Any code that affects the game should be in the adBreakStart and adBreakComplete
event listeners.

GAME ENGINE GUIDES
If your game is in Unity and you are having trouble getting either of these functions to work, please
reference our Unity API integration instructions here.
If your game is in Construct 3 and you are having trouble getting these functions to work, please
reference out Construct 3 API integration guide here. If the first link doesn’t work, try this
If your game is in GameMaker and you are having trouble getting these functions to work, please
reference our GameMaker API integration guide here.
If your game is in Godot and you are having trouble getting either of these functions to work, please
reference our Godot API integration instructions here."


CMG API INTEGRATION WITH Godot 3.X
"CoolMath API Integration with Godot
Using Godot 3.4+ and GDScript
Document written by James Lecomte: @hamezii_

Precursor Warning regarding Viewports: (from Godot 3.2, may now be obsolete)
Currently, using Viewport nodes inside of ViewportContainer nodes means that the contents will not render when being run on the Coolmath sites. Replace all instances of ViewportContainers in your project to fix this issue. 



This document covers 5 topics:
Coolmathgames Game Event Functions
Site Locking
Unlock All Levels
Ad Break Logic
HTML Export customisation


Coolmathgames Game Event Functions

Start Game
Place the following line of code at the point where you start a new game.
JavaScript.eval('window.parent.postMessage({"cm_game_event": true, "cm_game_evt": "start", "cm_game_lvl": 0}, "*");', true)

Start Level (level_num)
Place the following line of code at the point where you start a level (with the level number being level_num).
JavaScript.eval('window.parent.postMessage({"cm_game_event": true, "cm_game_evt": "start", "cm_game_lvl": ' + str(level_num) + '}, "*");', true)

Restart Level (level_num)
Place the following line of code at the point where you restart a level (with the level number being level_num).
JavaScript.eval('window.parent.postMessage({"cm_game_event": true, "cm_game_evt": "replay", "cm_game_lvl": ' + str(level_num) + '}, "*");', true)



Site Locking
In your Main Scene (the scene that runs when your project starts), add a node, of type Node, as a child of the root node, and name this new node “DomainValidator”.

The current state of the the node tree, with DomainValidator as a child of the root node.

Add a script to this node. In the script, paste the following:

extends Node

var valid_domains = [
	“www.coolmathgames.com”,
	“edit.coolmathgames.com”,
	“stage.coolmathgames.com”,
	“stage-edit.coolmathgames.com”,
“dev.coolmathgames.com”,
“m.coolmathgames.com”,
“www.coolmath-games.com”,
“edit.coolmath-games.com”,
“dev.coolmath-games.com”,
“m.coolmath-games.com”
]


func is_valid():
	if OS.is_debug_build():
		return true
	if not OS.get_name()=="HTML5":
		return true
	return valid_domains.has(get_domain())

func get_domain():
	return str(JavaScript.eval("document.location.host"))

At the top of the _ready() function in the root node of your Main Scene, add:

func _ready():

if not $DomainValidator.is_valid():
	# Do stuff here if you want to do something at an invalid domain
	get_tree().free()
	return


Your program should now not be able run once it has been exported as HTML, except when run on the Coolmath sites.
Ad Break Logic

Copy the following code into the root node of your Main Scene. This contains the logic to wait for and act upon signals from the website when an ad is started and completed.
# JavaScript callbacks
var _callback_adbreak_start = JavaScript.create_callback(self, "_on_adbreak_start")
var _callback_adbreak_complete = JavaScript.create_callback(self, "_on_adbreak_complete")

func _ready():
if OS.get_name()=="HTML5":
JavaScript.get_interface("document").addEventListener("adBreakStart", _callback_adbreak_start)
JavaScript.get_interface("document").addEventListener("adBreakComplete", _callback_adbreak_complete)

func _on_adbreak_start(args):
	JavaScript.get_interface("console").log("AdBreak Started")
	#TODO:  Developer needs to add the logic to pause the game and sound here.
#Example:
	get_tree().paused = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	

func _on_adbreak_complete(args):
	JavaScript.get_interface("console").log("AdBreak Completed")
	#TODO:  Developer needs to add the logic to resume the game and sound here. 
#Example:
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)


How the _on_adbreak_start and _on_adbreak_complete methods are implemented should depend on the specifics of each game, but the above should work for most projects. Note that this will not work for projects that make use of the get_tree().paused functionality in strange ways (for example, if the Pause Mode of some nodes are configured to be able to be active while the project is paused).

Note: The adBreakComplete signal will always be called whenever cmgAdBreak is called, while adBreakStart will only sometimes be triggered when an advertisement is actually displayed (cmgAdBreak will sometimes skip showing an advertisement if the length of time since the previous ad is too short). Make sure to take this into account when implementing your functions.

Prompting an Ad Break (cmgAdBreak)
To prompt an ad break, run the following line of code at the point where you would want the ad break to be able to occur:
JavaScript.eval("cmgAdBreak();", true)




HTML Export (Head Include)
In the Project>Export window, include the following lines in the Head Include property of the HTML5 export options:

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.3/jquery.min.js"></script>

<script type="text/javascript" src="https://www.coolmathgames.com/sites/default/files/cmg-ads.js"></script>




This provides access to the cmgAdBreak JavaScript command that we use to prompt the website when we would like to show an ad, as well as the adBreakStart and adBreakComplete signals.
"