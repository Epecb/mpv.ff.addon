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
    sendRequest();
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
