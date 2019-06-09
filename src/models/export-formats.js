// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

class Format {

  constructor({id, group, icon, needs, maxColumns}) {
    // Sigh, it's either this or list redundant info.
    this.id = id;
    this.group = group;
    this.maxColumns = maxColumns;
    const ext = this.id === 'tab' ? 'tsv' : this.id;
    const EXT = ext.toUpperCase();
    if (icon == null) { icon = ext; }
    if (needs == null) { needs = []; }
    const desc = `export.format.description.${ EXT }`;
    const name = `export.format.name.${ EXT }`;
    _.extend(this, {icon, desc, name, needs, ext, EXT});
  }

  toString() { return this.ext; }

  toJSON() { return {id: this.id, group: this.group, icon: this.icon, needs: this.needs, ext: this.ext}; }

  // Return true if this format has no requirements, or if at least
  // one of its required types are present.
  isSuitable(availableTypes) {
    if (this.needs.length === 0) { return true; }
    return _.any(this.needs, needed => availableTypes[needed]);
  }
}

// There are no good bio icons in the font-awesome
// set, but there are tickets to get them put in. Maybe
// one day soon these will work.
const formats = [
  new Format({id: 'tab', group: 'flat'}),
  new Format({id: 'csv', group: 'flat'}),
  new Format({id: 'xml',  group: 'machine'}),
  new Format({id: 'json', group: 'machine'}),
  new Format({id: 'fasta', group: 'bio', icon: 'dna', needs: ['Protein', 'SequenceFeature'], maxColumns: 1}),
  new Format({id: 'gff3',  group: 'bio', icon: 'dna', needs: ['SequenceFeature']}),
  new Format({id: 'bed',   group: 'bio', icon: 'dna', needs: ['SequenceFeature']}),
  new Format({id: 'fake',   group: 'fake', icon: 'fake', needs: ['Department']}),
  new Format({id: 'fake_2', group: 'fake', icon: 'fake', needs: ['Company']})
];

exports.getFormat = id => _.findWhere(formats, {id});

exports.getFormats = availableTypes =>
  (() => {
    const result = [];
    for (let f of Array.from(formats)) {       if (f.isSuitable(availableTypes)) {
        result.push(f);
      }
    }
    return result;
  })()
;

exports.registerFormat = ({id, icons, needs}) => formats.push(new Format(id, icons, needs));
