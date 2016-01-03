import control from 'control';

class InProgressActions {
  constructor() {
    this.generateActions(
      'requestRepoPulseStart'
    );
  }
}

export default control.createActions(InProgressActions);
