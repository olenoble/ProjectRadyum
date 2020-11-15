# ProjectRadyum

Credits<br><br>
<ol>
<li>Mention Jasmine<br>
<li>Tools (incl. GUI TASM / TD, Grafx, dp2e, wex editor, piskel, etc...)<br>
<li>discuss synthwave<br>
<li>discuss project evolution and reflection in hindsight<br>
<li> add ref to https://open.spotify.com/playlist/5jXZCjqxnjHr4EzJneGc0T
</ol>


TO DO (REQUIRED)<br><br>
<ol>
<li>When releasing code - remove all c:\ (only useful for TD)<br>
<li>Change QR code to point to gift page. Create blog page for gift for winner (with encrypted zipped up data)<br>
</ol>

<br><br>
TO DO (If enough time)<br><br>
<ol>
<li>Improve collision detection (check entire side)<br>
</ol>

<br><br>
Minor fixes<br><br>
<ol>
</ol>


<br><br>
Speed analysis with music: <br>
<ol>
<li>Using COPY_VIDEOBUFFER_SUPRATILE -> 8.25 / 7.92 / 7.99 / 8.08 / 7.92 ~8s for 10 back & forth -> 0.8s per screen cross.
    This represents (320 - 32) / 7 frames ~ 41 frames --> 51 frames per seconds<br>
<li>Using COPY_VIDEOBUFFER_SEMIFAST -> 8.39 / 8.17 / 7.94 / 8.09 / 8.11  ~8.14s for 10 back & forth -> 0.814s per screen cross.
This represents (320 - 32) / 7 frames ~ 41 frames --> 50 frames per seconds<br>
</ol>
