use 5.14.0;
use warnings;


#use Map::Metro::Grammar::;

package Map::Metro::Grammar  {
    use Regexp::Grammars;

    qr{
        <grammar: Map::Metro>
<nocontext:>
        <token: LineBreak>          \n
        <token: AnyCharacter>       [^\n]
        <token: AnyCharacterString> <.AnyCharacter>+
        <token: SpaceChar>          [ \t]
        <token: OptSpace>           <.SpaceChar>*
        <token: Space>              <.SpaceChar>+
        <token: LeftBracket>        \<
        <token: RightBracket>       \>
        <token: Slash>              /
        <token: Int>                \d+
        <token: AlphaNumeric>       [\da-zA-Z]
        <token: ANString>           [\da-zA-Z]+
        <token: Pipe>               \|
        <token: NonPipe>            [^|]
        <token: NPString>           [^|]+
        

        <token: StartStationList>   <LeftBracket>stations<RightBracket><.LineBreak>
        <token: EndStationList>     <LeftBracket><Slash>stations<RightBracket>
        <rule: Station>             ^<StationName=AnyCharacterString>^

        <token: StartLineList>      <LeftBracket>lines<RightBracket><.LineBreak>
        <token: EndLineList>        <LeftBracket><Slash>lines<RightBracket>
  #      <rule: Line>                    <LineId=ANString><.Pipe>
  #                                      <LineNumber=NPString><.Pipe>
  #                                      <StartStation=NPString><.Pipe>
  #                                      <EndStation=AnyCharacterString><.LineBreak>
        <rule: Line>                    <LineId=AnyCharacterString>

        
        
        <token: StartSegmentList>   <LeftBracket>segments<RightBracket><.LineBreak>
        <token: EndSegmentList>     <LeftBracket><Slash>segments<RightBracket><.LineBreak>
  #      <rule: Segment>                 <SegmentLines=NPString><.Pipe>
  #                                      <StartStation=NPString><.Pipe>
  #                                      <EndStation=AnyCharacterString><.LineBreak>
        <rule: Segment>                 <SegmentLines=AnyCharacterString><.LineBreak>

        <objrule: Map::Metro::Grammar::StationList>         <.StartStationList><[Station]>+<.EndStationList>
        <objrule: Map::Metro::Grammar::LineList>            <.StartLineList><[Line]>+<.EndLineList>
        <objrule: Map::Metro::Grammar::SegmentList>         <.StartSegmentList><[Segment]>+<.EndSegmentList>

        <objrule: Map::Metro::Grammar::Spec>                <StationList><LineList><SegmentList>
    }xm;

}
__END__
<token: SegmentLineIds>     <.OptSpace><SegmentLines=NPString>
<token: SegmentLineIds>     <LineId=ANString>(,<.OptSpace><[Line=ANString]>)*
<token: SegmentLineIds>     <.OptSpace><SegmentLines=NPString>
