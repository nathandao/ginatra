import React from 'react';

class SectionContainer extends React.Component {
  render() {
    return (
      <section className="section-container">
        { this.props.children }
      </section>
    );
  }
}

export default SectionContainer;
