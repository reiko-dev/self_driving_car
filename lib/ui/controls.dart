import 'package:self_driving_car/controller/model/car.dart';

class Controls {
  bool forward = false;
  bool reverse = false;
  bool left = false;
  bool right = false;
  ControlType type;

  Controls(this.type) {
    switch (type) {
      case ControlType.keys:
        _addKeyboardListeners();
        break;
      case ControlType.dummy:
        forward = true;
        break;
      case ControlType.ia:
        break;
    }
  }

  _addKeyboardListeners() {
    //TODO: Add keyboard listeners
    // document.onkeydown = (event) => {
    //     switch(event.key) {
    //         case "ArrowLeft":
    //             this.left = true;
    //             break;
    //         case "ArrowRight":
    //             this.right = true;
    //             break;
    //         case "ArrowUp":
    //             this.forward = true;
    //             break;
    //         case "ArrowDown":
    //             this.reverse = true;
    //             break;
    //     }
    // };

    // document.onkeyup = (event) => {
    //     switch (event.key) {
    //         case "ArrowLeft":
    //             this.left = false;
    //             break;
    //         case "ArrowRight":
    //             this.right = false;
    //             break;
    //         case "ArrowUp":
    //             this.forward = false;
    //             break;
    //         case "ArrowDown":
    //             this.reverse = false;
    //             break;
    //     }
    // };
  }
}
