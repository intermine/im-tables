// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let PieChart;
const _ = require('underscore');
const $ = require('jquery');
const d3 = require('d3-browserify');

const Options = require('../../options');

const VisualisationBase = require('./visualisation-base');

const KEY = d => d.data.get('id');

const DONUT = d3.layout.pie().value(d => d.get('count'));

const TWEEN_START = {
  startAngle: 0,
  endAngle: 0
};

const getChartPalette = function() {
  const colors = Options.get('PieColors');
  const paint = _.isFunction(colors) ?
    colors
  :
    d3.scale[colors]();

  return d => paint(d.data.get('id'));
};

const getStartPosition = function(model) { let left;
return (left = model.get('currentPieCoords')) != null ? left : TWEEN_START; };

const opacity = function(d) { if (d.data.get('visible')) { return 1; } else { return 0.25; } };

const getEndPosition = (startAngle, endAngle, model) =>
  ({
    startAngle,
    endAngle,
    selected: (model.get('selected') ? 1 : 0)
  })
;

// close over the arc function.
const getArcTween = arc => function({startAngle, endAngle, data}) {
  // Interpolate from start position to current position.
  const model = data;
  const start = getStartPosition(model);
  const end = getEndPosition(startAngle, endAngle, model);
  const getDatumAtTime = d3.interpolateObject(start, end); // A dataspace interpolator
  model.set({currentPieCoords: getDatumAtTime(1)}); // save the final result for next time.
  return t => arc(getDatumAtTime(t)); // The arc for each point in time.
} ;

// Predicate that determines if the mid-point of a segment is past six-o'clock in position.
const isPastSixOClock = d => ((d.endAngle + d.startAngle) / 2) > Math.PI;

// Get an arc function that reads objects with three properties:
//  - innerRadius
//  - outerRadius
//  - selected :: float between 0 - 1
const getArc = (outerRadius, innerRadius, selectionBump) =>
  d3.svg.arc()
        .startAngle(d => d.startAngle)
        .endAngle(d => d.endAngle)
        .innerRadius(d => innerRadius + (d.selected * selectionBump))
        .outerRadius(d => outerRadius + (d.selected * selectionBump))
;

module.exports = (PieChart = (function() {
  PieChart = class PieChart extends VisualisationBase {
    static initClass() {
  
      this.prototype.chartWidth = 120;
      this.prototype.chartHeight = 120;
  
      this.prototype.className = 'im-pie-chart';
    }

    initialize() {
      super.initialize(...arguments);
      this.listenTo(this.model.items, 'change:selected change:visible', this.update);
      this.listenTo(Options, 'change:PieColors', this.onChangePalette);
      return this.onChangePalette();
    }

    onChangePalette() {
      this.colour = getChartPalette();
      return this.update();
    }

    _drawD3Chart() {
      const h = this.chartHeight;
      const w = this.$el.closest(':visible').width();
      const outerRadius = h * 0.4;
      const innerRadius = h * 0.1;
      const selectionBump = h * 0.08;

      const chart = d3.select(this.el).append('svg')
                .attr('class', 'chart')
                .attr('height', h)
                .attr('width', w);

      this.arc = getArc(outerRadius, innerRadius, selectionBump);

      this.arc_group = chart.append('svg:g')
                        .attr('class', 'arc')
                        .attr('transform', `translate(${ w / 2},${h / 2})`);

      const centre_group = chart.append('svg:g')
                          .attr('class', 'center_group')
                          .attr('transform', `translate(${ w / 2},${h / 2})`);

      const label_group = chart.append("svg:g")
                          .attr("class", "label_group")
                          .attr("transform", `translate(${w / 2},${h / 2})`);

      const whiteCircle = centre_group.append("svg:circle")
                                .attr("fill", "white")
                                .attr("r", innerRadius);

      return this.update();
    }

    // For each item, add a wedge with the correct classes and a tooltip.
    enter(selection) {
      const container = this.el;
      const total = this.model.items.reduce(((sum, m) => sum + m.get('count')), 0);
      const percent = d => ((d.data.get('count') / total) * 100).toFixed(1);
      const activateTooltip = function(d) {
        const $el = $(this); // functions are called in the context of the SVG node.
        const title = `${ d.data.get('item') }: ${ percent(d) }%`;
        const placement = (isPastSixOClock(d)) ? 'left' : 'right';
        return $el.tooltip({title, placement, container});
      };
      return selection.append('svg:path')
               .attr('class', 'donut-arc')
               .on('click', d => d.data.toggle('selected'))
               .on('mouseover', d => d.data.mousein())
               .on('mouseout', d => d.data.mouseout())
               .each(activateTooltip);
    }

    // If a wedge has gone away, remove it.
    exit(selection) { return selection.remove(); }

    getChartData() { return this.model.items.models.slice(); }

    // all update does is push selected elements out a bit - there is no enter/exit
    // going on. At least, there shouldn't be. 
    update() {
      if (this.arc_group == null) { return; }
      const paths = this.arc_group.selectAll('path').data((DONUT(this.getChartData())), KEY);

      this.exit(paths.exit());
      this.enter(paths.enter());

      const {DurationShort, Easing} = Options.get('D3.Transition');

      paths.attr('fill', this.colour);
      return paths.transition()
        .duration(DurationShort)
        .ease(Easing)
        .style('opacity', opacity)
        .attrTween('d', (getArcTween(this.arc)));
    }
  };
  PieChart.initClass();
  return PieChart;
})());

