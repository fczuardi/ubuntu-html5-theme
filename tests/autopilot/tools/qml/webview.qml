import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0

Rectangle {
    id: root
    objectName: "webviewContainer"
    width: 640
    height: 640

    property string url

    signal resultUpdated(string message)

    function __gentid() {
        return Math.random() + '';
    }
    function __wrapJsCommands(commands) {
        return '(function() { ' + commands + ' })();'
    }
    function __createResult(result, tid) {
        return JSON.stringify({result: result, tid: tid});
    }
    function __dumpValue(v) {
    	if (typeof(v) === "string") {
	   return "'" + v + "'";
	}
	return v;
    }
    function __setupClosedVariables(variables) {
        var variableDeclStatements = '';
        for (var variable in variables) {
	    if (variables.hasOwnProperty(variable)) {
	        variableDeclStatements += 'var ' + variable + ' = ' + __dumpValue(variables[variable]) + ';';
	    }
	}
	return variableDeclStatements;
    }

    function clickElementById(id) {
        var tid = __gentid();
	var statement = 'document.getElementById("' + id + '").click();';

        webview.experimental.evaluateJavaScript(__wrapJsCommands(statement),
		function(result) { root.resultUpdated(root.__createResult(result)); });
    }
    function clickAnyElementBySelector(selector) {
        var tid = __gentid();
	var statement = 'document.querySelectorAll("' + selector + '")[0].click();';

        webview.experimental.evaluateJavaScript(__wrapJsCommands(statement),
		function(result) { root.resultUpdated(root.__createResult(result)); });
    }
    function elementWithIdHasAttribute(id,attribute,value) {
        var tid = __gentid();
	function __hasAttributeWithId() {
	    try { return document.querySelector('#' + id).getAttribute(attribute) === value; } catch (e) {};
	    return false;
	};

	var statement = __setupClosedVariables({'id': id, 'attribute': attribute, 'value': value});
	statement += __hasAttributeWithId.toString();
	statement += "; return __hasAttributeWithId(id,attribute,value); "

        webview.experimental.evaluateJavaScript(__wrapJsCommands(statement),
		function(result) { root.resultUpdated(root.__createResult(result, tid)); });
    }
    function isNodeWithIdVisible(id) {
        var tid = __gentid();
	function __isNodeWithIdVisible() {
	    try { return document.getElementById(id).style.display !== "none"; } catch (e) { return e.toString(); };
	    return false;
	};

	var statement = __setupClosedVariables({'id': id});
	statement += __isNodeWithIdVisible.toString();
	statement += "; return __isNodeWithIdVisible(id); "
	
        webview.experimental.evaluateJavaScript(__wrapJsCommands(statement),
		function(result) { root.resultUpdated(root.__createResult(result, tid)); });
    }
    function getAttributeForElementWithId(id,attribute) {
        var tid = __gentid();
	function __getAttributeWithId() {
	    try { return document.querySelector('#' + id).getAttribute(attribute); } catch (e) {};
	    return undefined;
	};

	var statement = __setupClosedVariables({'id': id, 'attribute': attribute});
	statement += __getAttributeWithId.toString();
	statement += "; return __getAttributeWithId(id,attribute,value); "

        webview.experimental.evaluateJavaScript(__wrapJsCommands(statement),
		function(result) { root.resultUpdated(root.__createResult(result, tid)); });
    }

    WebView {
        objectName: "webview"
        id: webview

	url: parent.url
        width: parent.width

	anchors {
	    top: parent.top
            bottom: addressbar.top
            right: parent.right
            left: parent.left
	}

        height: parent.height - 100

        experimental.userScripts: []
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.preferences.developerExtrasEnabled: true

        experimental.userAgent: {
            return "Mozilla/5.0 (iPad; CPU OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
        }
    }

    TextInput {
        id: addressbar
	objectName: "addressbar"
	width: parent.width - 100
	height: parent.height - 100

	enabled: true
	color: "red"
	readOnly: false
	selectByMouse: true

	anchors {
	    top: webview.bottom
            bottom: parent.bottom
            right: browseButton.left
            left: parent.left
	}
    }

    MouseArea {
        objectName: "browseButton"
    	id: browseButton
	width: 100
	height: 100

	onClicked: {
	    parent.url = addressbar.text
	}

	anchors {
	    top: webview.bottom
            bottom: parent.bottom
            right: parent.right
            left: addressbar.right
	}
    }   
}
