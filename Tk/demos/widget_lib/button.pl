# button.pl

sub button {

    # Create a top-level window that displays a bunch of buttons.

    my($demo) = @ARG;

    $BUTTON->destroy if Exists($BUTTON);
    $BUTTON = $mw->Toplevel;
    my $w = $BUTTON;
    dpos $w;
    $w->title('Button Demonstration');
    $w->iconname('button');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
	-text       => 'If you click on any of the four buttons below, the background of the button area will change to the color indicated in the button.   You can press Tab to move among the buttons, then press Space to invoke the current button.',
    );
    $w_msg->pack(-side => 'top');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $color;
    foreach $color ('PeachPuff1', 'LightBlue1', 'SeaGreen2', 'Yellow1') {  
	my $b = $w->Button(
            -text => $color,
            -width => 10,
            -command => [
                sub {
		    my($w, $c) = @ARG;
		    $w->configure(-background => lc($c));
		}, $w, $color,
            ],
        );
	$b->pack(-side => 'top', -expand => 'yes', -pady => 2);
    }

} # end button

1;
