# VOX flavor to your MovableType...
#
# Author: Yuji Takayama (http://code.sixapart.com)
# Released under the Artistic License
#
# $Id$

package MT::Plugin::ThisIsGood;

use strict;
use MT;
use MT::Plugin;
@MT::Plugin::ThisIsGood::ISA = qw(MT::Plugin);

use MT::Template::Context;
use MT::I18N qw( encode_text );

our $VERSION = '0.032';

my $plugin = new MT::Plugin::ThisIsGood({
    name            => "This is good for MT",
    version         => $VERSION,
    description     => "<MT_TRANS phrase=\"A Plugin for quick comment form\">",
    author_name     => "Yuji Takayama",
    author_link     => "http://code.sixapart.com/",
    l10n_class      => "ThisIsGood::L10N",
    config_template => 'config.tmpl',
    settings        => new MT::PluginSettings([
        ['comment_template', { Default => 'this is good' }]
    ]),
});

MT->add_plugin($plugin);
sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        tags => {
            function => {
                'ThisIsGood' => \&_hdlr_this_is_good,
            },
        },
        callbacks => {
            'CommentThrottleFilter',
                => \&throttle_filter,
        },
    });
}

sub _hdlr_this_is_good {
    my ($ctx, $args, $cond) = @_;

    my $blog = $ctx->stash('blog');
    my $config = $plugin->get_config_hash('blog:'.$blog->id);
    my $comment_template = $config->{comment_template};
    if (!$comment_template) {
        $config = $plugin->get_config_hash();
        $comment_template = $config->{comment_template};
    }

    my @template = split(/\n/, $comment_template);

    my $html = "<label for=\"quick-comment-text\">"
               .$plugin->translate("Quick Comment:")
               ."</label><select name=\"comment_template\" id=\"quick-comment-text\" onchange=\"doCommentPreview();\"><option value=\"\" selected=\"selected\">----</option>";
    foreach my $val (@template) {
        $html .= '<option value="'.$val.'">'.$val.'</option>';
    }
    $html .= '</select>';

    if (substr(MT->version_number, 0, 3) >= 5.1) {
        return $html;
    }
    else {
    return MT::I18N::encode_text($html, undef);
    }
}

sub throttle_filter {
    my ($eh, $app, $entry) = @_;
    my $q = $app->param;
    my $quick = $q->param('comment_template');
    my $original = $q->param('text');
    $q->param(-name=>'text', -value=>'<strong>'.$quick.'</strong><br />'.$original) if $quick;
    1;
}

1;
