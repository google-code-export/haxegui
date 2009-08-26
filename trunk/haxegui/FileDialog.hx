// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package haxegui;


//{{{ Imports
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import haxegui.Window;
import haxegui.containers.Container;
import haxegui.controls.Button;
import haxegui.controls.Image;
import haxegui.controls.Label;
import haxegui.events.DragEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.StyleManager;
import haxegui.utils.Align;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;


//{{{ FileDialog
/**
* FileDialog window<br/>
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class FileDialog extends Dialog {

	static var layoutXml = Xml.parse('
	<haxegui:Layout name="FileDialog">
		<haxegui:containers:Container name="Container">
		<haxegui:containers:VDivider/>
		</haxegui:containers:Container>
	</haxegui:Layout>
	').firstElement();

	//{{{ init
	public override function init(?opts:Dynamic=null) {
		box = new Size(480,320).toRect();
		type = WindowType.MODAL;

		layoutXml.set("name", name);

		XmlParser.apply(FileDialog.layoutXml, this);


		super.init(opts);
	}
	//}}}

}
//}}}