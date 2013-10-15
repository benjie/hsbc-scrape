HSBC Scrape
===========

Work in progress.

Purpose
-------

To download old statement history from HSBC (UK)'s personal online
banking, including downloading of the extended details of transactions.

Output
------

The script dumps each account to a JSON file with lots of data. Later
I'll make scripts to convert this JSON to CSV and possibly OFX if I can
be bothered. You can then import it into a spreadsheet or wherever.

Method
------

The script controls a web browser (probably firefox) via Selenium, doing
all the hard, boring, repetative work for you. It is careful to follow
the links/forms on the web pages rather than remembering URLs/etc in
order to get around HSBC's history issues. It only loads one page at a
time so as to not be disabled - this makes it slow but quite reliable.
It dumps out the data frequently so as to make recovery simpler in case
of crashes.

The script will prompt you for your internet banking ID, password and
your One Time Password from your DIGIPASS device. It will then log you
in to your internet banking using these details.

Security
--------

You are responsible for your own security whilst using this software.
Use it at your own risk. It's your responsibility to see if Selenium,
Firefox, or any other software used by this software logs your data, and
if so it's your responsibility to clear that data.

Do NOT use this software on an untrusted network or computer, it is NOT protected
with encryption.

The software does NOT automatically log you out when things are done, so
your session with HSBC still exists for a few minutes after the script
exits. If this is a problem for you then don't use this software!

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Running
-------

Run selenium-standalone-server in one terminal, then run `npm start` in
another and follow the prompts.

### Faster, less secure method

To save time you can pass your internet banking ID/password as options,
but **beware** - doing so may save them to your shell history:

` ./node_modules/.bin/coffee index.coffee -I IB0000000000 -p "correct horse battery staple"`

**PROTIP**: check out `HISTCONTROL` in `bash`, particularly
`ignorespace` to not log commands that start with a space. Check out
this [LinuxJournal article on HISTCONTROL][].

Or if you use `zsh` then check out `setopt histignorespace`.

Bugs
----

Pull requests welcome, please keep them focussed and tight - don't merge
a whole load of new features and a rewrite into one pull request!

[LinuxJournal article on HISTCONTROL]: http://www.linuxjournal.com/content/using-bash-history-more-efficiently-histcontrol
