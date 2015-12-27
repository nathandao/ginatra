import React from 'react';

class SectionContainer extends React.Component {
  render() {
    return (
      <div className="section-container">
        { this.props.children }
      </div>
    );
  }
}

export default SectionContainer;
