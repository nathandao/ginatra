import control from 'control';

class RepoPulseActions {
  constructor() {
    this.generateActions(
      'loadRepoPulse',
      'requestRepoPulseError'
    );
  }
}

export default control.createActions(RepoPulseActions);
