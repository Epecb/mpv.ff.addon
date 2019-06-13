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


function sendRequest(){
    browser.tabs.query({currentWindow: true}).then((tabs) => {
        for (let tab of tabs) {
            if (tab.active) {
                post('http://127.0.0.1:8888', 'POST', '{ "command": ["loadfile", "' + tab.url + '"] }');
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
    sendRequest();
});
