exports.type = Symbol && Symbol["for"] ? Symbol["for"]("react.element") : 0xeac7;

exports.createElement = function(type, props) {
  return {
    type: type,
    props: props,
    $$typeof: exports.type
  };
};

//# sourceMappingURL=../../../map/src/mocks/ReactElement.map
