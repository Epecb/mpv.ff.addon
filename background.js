// send post to url
function post(url, method, param) {
    var xhReq = new XMLHttpRequest();
    xhReq.onreadystatechange = function()
    {
        if(xhReq.readyState == 4 )
        {
            console.log(xhReq.responseText);
        }
    }
    // xhReq.open("GET", "http://localhost:8000/",true);
    xhReq.open( param == null ? "GET" : "POST", url, true);
    xhReq.setRequestHeader("Content-Type", "text/json");
    xhReq.send(param);
}


function sendRequest(cmd){
    browser.tabs.query({currentWindow: true}).then((tabs) => {
        for (let tab of tabs) {
            if (tab.active) {
                cmd.command[1] = tab.url;
                post('http://127.0.0.1:8888', 'POST', JSON.stringify(cmd));
            }
        }
    });
}


// menu bar button press
browser.browserAction.onClicked.addListener(() => {
    var cmd = JSON.parse('{ "command":[]}');
        cmd.command[0] = 'loadfile';
    sendRequest(cmd);
});


// on hotkey
browser.commands.onCommand.addListener((command) => {
    var cmd = JSON.parse('{ "command":[]}');
        cmd.command[0] = 'loadfile';
        cmd.command[1] = '';
    switch (command) {
        case 'loadfile':
            // console.log(cmd);
            break;
        case 'append-play':
            cmd.command[2] = 'append-play';
            // console.log(cmd);
            break;
        default:
    }
    sendRequest(cmd);
});


// Context menu on loadfile
browser.contextMenus.create({
    id: "loadfile",
    title: "loadfile",
    contexts: ["link"],
});


// Context menu on append-play
browser.contextMenus.create({
    id: "append-play",
    title: "append-play",
    contexts: ["link"],
});


// on menu click
browser.contextMenus.onClicked.addListener((info, tab) => {
    var cmd = JSON.parse('{ "command":[]}');
        cmd.command[0] = 'loadfile';
        cmd.command[1] = '';
    switch (info.menuItemId) {
        case 'loadfile':
            break;
        case 'append-play':
            cmd.command[2] = 'append-play';
            break;
        default:
    }
    cmd.command[1] = info.linkUrl;
    post('http://127.0.0.1:8888', 'POST', JSON.stringify(cmd));
});
